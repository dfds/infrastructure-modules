# --------------------------------------------------
# Get remote state of cluster deployment
# --------------------------------------------------

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "${var.aws_region}/k8s-${var.eks_cluster_name}/cluster/terraform.tfstate"
    region = var.terraform_state_region
  }
}


# --------------------------------------------------
# Cluster metadata and authenticate
# --------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster_name
}


# --------------------------------------------------
# Generate EKS fully-qualified domain name
# --------------------------------------------------

locals {
  eks_fqdn = "${var.eks_cluster_name}.${var.workload_dns_zone_name}"
}


# --------------------------------------------------
# Determine parent DNS zone name
# --------------------------------------------------

locals {
  workload_dns_zone_list = split(".", var.workload_dns_zone_name)
  core_dns_zone_list = slice(
    local.workload_dns_zone_list,
    1,
    length(local.workload_dns_zone_list),
  )
  core_dns_zone_name = join(".", local.core_dns_zone_list)
}

# --------------------------------------------------
# Monitoring namespace name
# --------------------------------------------------

locals {
  monitoring_namespace_name = "monitoring"
}


# --------------------------------------------------
# Get Route 53 zones and ids
# --------------------------------------------------

data "aws_route53_zone" "workload" {
  name         = "${var.workload_dns_zone_name}."
  private_zone = false
}

data "aws_route53_zone" "core" {
  count        = signum(length(var.traefik_alb_auth_core_alias) + length(var.traefik_alb_anon_core_alias))
  name         = "${local.core_dns_zone_name}."
  private_zone = false
  provider     = aws.core
}

# Get DNS zone IDs
locals {
  workload_dns_zone_id = element(concat(data.aws_route53_zone.workload[*].zone_id, [""]), 0)
  core_dns_zone_id     = element(concat(data.aws_route53_zone.core[*].zone_id, [""]), 0)
}


# --------------------------------------------------
# Generate Traefik authenticated ALB app registration reply URLs
# --------------------------------------------------

locals {
  traefik_alb_auth_endpoints = concat(
    var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy ? concat(
      [
        "internal.${local.eks_fqdn}"
      ],
      var.traefik_alb_auth_core_alias
    ) : [],
    var.traefik_blue_variant_deploy && var.traefik_green_variant_deploy ?
    [
      "traefik-blue-variant.${local.eks_fqdn}:8443",
      "traefik-green-variant.${local.eks_fqdn}:9443"
    ] : [],
    var.traefik_blue_variant_deploy ?
    [
      "traefik-blue-variant.${local.eks_fqdn}"
    ] : [],
    var.traefik_green_variant_deploy ?
    [
      "traefik-green-variant.${local.eks_fqdn}"
    ] : [],
  )
  traefik_alb_auth_appreg_reply_join        = "^${join("$,^", local.traefik_alb_auth_endpoints)}$"
  traefik_alb_auth_appreg_reply_replace_pre = replace(local.traefik_alb_auth_appreg_reply_join, "^", "https://")
  traefik_alb_auth_appreg_reply_replace_end = replace(
    local.traefik_alb_auth_appreg_reply_replace_pre,
    "$",
    "/oauth2/idpresponse",
  )
  traefik_alb_auth_appreg_reply_urls = split(",", local.traefik_alb_auth_appreg_reply_replace_end)
}

locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
}

# --------------------------------------------------
# Monitoring namespace iam role annotations
# --------------------------------------------------

locals {
  grafana_iam_role_name = "${var.eks_cluster_name}-monitoring-grafana-cloudwatch"
  grafana_iam_role_arn  = "arn:aws:iam::${var.aws_workload_account_id}:role/${local.grafana_iam_role_name}"
}

# --------------------------------------------------
# Grafana Cloudwatch IAM role
# --------------------------------------------------

data "aws_iam_policy_document" "cloudwatch_metrics" {
  statement {
    effect = "Allow"

    actions = [
      "tag:GetResources",
      "ec2:DescribeTags",
      "ec2:DescribeRegions",
      "ec2:DescribeInstances",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "cloudwatch:DescribeAlarmsForMetric"
    ]

    resources = ["*"]
  }
}

data "aws_caller_identity" "workload_account" {
}

locals {
  oidc_issuer = trim(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
}

data "aws_iam_policy_document" "cloudwatch_metrics_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.workload_account.account_id}:oidc-provider/${local.oidc_issuer}",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${local.monitoring_namespace_name}:${var.monitoring_kube_prometheus_stack_grafana_serviceaccount_name}"]
      variable = "${local.oidc_issuer}:sub"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

# --------------------------------------------------
# Loadbalancer service account
# --------------------------------------------------

data "aws_elb_service_account" "main" {}

# --------------------------------------------------
# Loadbalancer access logs S3 bucket policy
# --------------------------------------------------

locals {
  alb_access_log_bucket_name   = "dfds-k8s-${var.eks_cluster_name}-alb-access-logs"
  alb_access_log_bucket_policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.alb_access_log_bucket_name}/*/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

# --------------------------------------------------
# Blackbox Exporter
# --------------------------------------------------

locals {
  blackbox_exporter_monitoring_atlantis = var.atlantis_deploy ? [{
    "name"   = "atlantis"
    "url"    = "http://atlantis.${var.atlantis_namespace}/healthz"
    "module" = "http_2xx"
  }] : []

  blackbox_exporter_monitoring_grafana = var.monitoring_kube_prometheus_stack_deploy ? [{
    "name"   = "grafana"
    "url"    = "http://monitoring-grafana.monitoring/api/health"
    "module" = "http_2xx"
  }] : []

  blackbox_exporter_monitoring_traefik_blue_variant = var.traefik_blue_variant_deploy ? [{
    "name"   = "traefik-blue-variant"
    "url"    = "http://traefik-blue-variant.traefik-blue-variant:9000/ping"
    "module" = "http_2xx"
  }] : []

  blackbox_exporter_monitoring_traefik_green_variant = var.traefik_green_variant_deploy ? [{
    "name"   = "traefik-green-variant"
    "url"    = "http://traefik-green-variant.traefik-green-variant:9000/ping"
    "module" = "http_2xx"
  }] : []


  blackbox_exporter_monitoring_targets = concat(
    local.blackbox_exporter_monitoring_atlantis,
    local.blackbox_exporter_monitoring_grafana,
    local.blackbox_exporter_monitoring_traefik_blue_variant,
    local.blackbox_exporter_monitoring_traefik_green_variant,
    var.blackbox_exporter_monitoring_targets
  )
}

# --------------------------------------------------
# Flux CD
# --------------------------------------------------

locals {
  fluxcd_apps_repo_url = "${var.fluxcd_apps_git_provider_url}${var.fluxcd_apps_repo_owner}/${var.fluxcd_apps_repo_name}"
  fluxcd_custom_apps_repo_url = "${var.fluxcd_apps_git_provider_url}${var.fluxcd_apps_repo_owner}/${var.fluxcd_custom_apps_repo_name}"

}

# --------------------------------------------------
# Atlantis
# --------------------------------------------------

locals {
  confluent_env_vars_for_atlantis = {
    TF_VAR_crossplane_provider_confluent_email    = var.crossplane_provider_confluent_email
    TF_VAR_crossplane_provider_confluent_password = var.crossplane_provider_confluent_password
  }

  atlantis_env_vars_default = {
    PRODUCTION_AWS_ACCESS_KEY_ID                                        = var.atlantis_aws_access_key
    PRODUCTION_AWS_SECRET_ACCESS_KEY                                    = var.atlantis_aws_secret
    PRODUCTION_TF_VAR_slack_webhook_url                                 = var.slack_webhook_url
    PRODUCTION_TF_VAR_monitoring_kube_prometheus_stack_slack_webhook    = var.monitoring_kube_prometheus_stack_slack_webhook
    STAGING_AWS_ACCESS_KEY_ID                                           = var.atlantis_staging_aws_access_key
    STAGING_AWS_SECRET_ACCESS_KEY                                       = var.atlantis_staging_aws_secret
    STAGING_TF_VAR_slack_webhook_url                                    = var.staging_slack_webhook_url
    STAGING_TF_VAR_monitoring_kube_prometheus_stack_slack_webhook       = var.monitoring_kube_prometheus_stack_staging_slack_webhook
    SHARED_ARM_TENANT_ID                                                = var.atlantis_arm_tenant_id
    SHARED_ARM_SUBSCRIPTION_ID                                          = var.atlantis_arm_subscription_id
    SHARED_ARM_CLIENT_ID                                                = var.atlantis_arm_client_id
    SHARED_ARM_CLIENT_SECRET                                            = var.atlantis_arm_client_secret
    SHARED_TF_VAR_monitoring_kube_prometheus_stack_azure_tenant_id      = var.monitoring_kube_prometheus_stack_azure_tenant_id
    SHARED_TF_VAR_fluxcd_bootstrap_repo_owner_token                     = var.fluxcd_bootstrap_repo_owner_token
    SHARED_TF_VAR_atlantis_github_token                                 = var.atlantis_github_token
    PRODUCTION_PRIME_AWS_ACCESS_KEY_ID                                  = var.prime_aws_access_key
    PRODUCTION_PRIME_AWS_SECRET_ACCESS_KEY                              = var.prime_aws_secret
    PRODUCTION_PREPRIME_AWS_ACCESS_KEY_ID                               = var.preprime_aws_access_key
    PRODUCTION_PREPRIME_AWS_SECRET_ACCESS_KEY                           = var.preprime_aws_secret
    PRODUCTION_PREPRIME_BACKUP_REPORTS_SLACK_WEBHOOK_URL                = var.preprime_backup_reports_slack_webhook_url
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_KAFKA_BROKER                       = var.aws_account_manifests_kafka_broker
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_KAFKA_USERNAME                     = var.aws_account_manifests_kafka_username
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_KAFKA_PASSWORD                     = var.aws_account_manifests_kafka_password
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_HARDENED_MONITORING_SLACK_TOKEN    = var.aws_account_manifests_hardened_monitoring_slack_token
    CONFLUENT_KAFKA_PROD_PROMETHEUS_METRICS_EXPORTER_HELLMAN_API_KEY    = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_key
    CONFLUENT_KAFKA_PROD_PROMETHEUS_METRICS_EXPORTER_HELLMAN_API_SECRET = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_secret
  }

  atlantis_env_vars = var.crossplane_deploy ? merge(local.atlantis_env_vars_default, local.confluent_env_vars_for_atlantis) : local.atlantis_env_vars_default
}

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
  workload_dns_zone_id = element(concat(data.aws_route53_zone.workload.*.zone_id, [""]), 0)
  core_dns_zone_id     = element(concat(data.aws_route53_zone.core.*.zone_id, [""]), 0)
}


# --------------------------------------------------
# Generate Traefik authenticated ALB app registration reply URLs
# --------------------------------------------------

locals {
  traefik_alb_auth_endpoints = concat(
    ["internal.${local.eks_fqdn}"],
    ["grafana.${local.eks_fqdn}"],
    var.traefik_alb_auth_core_alias,
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

# ---------------------------------------------------------------------
# Traefik dashboard secure access
#
# Caution:
# Each instance of the traefik sub module needs its
# own locals to calculate the ingress host to use for
# that instance of Traefik. That is to avoid sending
# too many irrelevant variables into the sub module.
#
# Logic explained:
# IF traefik_alb_auth_core_alias in services/terragrunt.hcl contains
#   traefik.dfds.cloud
# THEN use traefik.dfds.cloud as Traefik dashboard ingress host
# ELSE use internal.<cluster-name>.<capability-name>.dfds.cloud
#
# ---------------------------------------------------------------------

locals {
  traefik_flux_dashboard_ingress_prod_host = "traefik.${local.core_dns_zone_name}"
  traefik_flux_alb_auth_dns_name           = try(module.traefik_alb_auth_dns.record_name["0"], "traefik.${var.eks_cluster_name}")
  traefik_flux_dashboard_ingress_host = contains(
    var.traefik_alb_auth_core_alias,
    local.traefik_flux_dashboard_ingress_prod_host
  ) ? local.traefik_flux_dashboard_ingress_prod_host : "${local.traefik_flux_alb_auth_dns_name}.${var.workload_dns_zone_name}"
  traefik_flux_is_using_alb_auth = length(regexall("^.*traefik.*", join(" ", var.traefik_alb_auth_core_alias))) > 0 ? true : false
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

  blackbox_exporter_monitoring_traefik = var.traefik_flux_deploy ? [{
    "name"   = "traefik"
    "url"    = "http://traefik.traefik:9000/ping"
    "module" = "http_2xx"
  }] : []

  blackbox_exporter_monitoring_targets = concat(
    local.blackbox_exporter_monitoring_atlantis,
    local.blackbox_exporter_monitoring_grafana,
    local.blackbox_exporter_monitoring_traefik,
    var.blackbox_exporter_monitoring_targets
  )
}

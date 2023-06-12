# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}


# --------------------------------------------------
# Provider configuration
# --------------------------------------------------

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "core"
}

locals {
  aws_assume_logs_role_arn = var.aws_assume_logs_role_arn == null || var.aws_assume_logs_role_arn == "" ? var.aws_assume_role_arn : var.aws_assume_logs_role_arn
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = local.aws_assume_logs_role_arn
  }

  alias = "logs"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  # config_path            = pathexpand("~/.kube/${var.eks_cluster_name}.config") # no datasources in providers allowed when importing into state (remember to flip above bool to load config)
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
    # config_path            = pathexpand("~/.kube/${var.eks_cluster_name}.config") # no datasources in providers allowed when importing into state (remember to flip above bool to load config)
  }
}

provider "github" {
  token = var.atlantis_github_token
  owner = var.atlantis_github_owner
  alias = "atlantis"
}

provider "github" {
  token = var.fluxcd_bootstrap_repo_owner_token
  owner = var.fluxcd_bootstrap_repo_owner
  alias = "fluxcd"
}

provider "random" {
}

provider "azuread" {

}

# --------------------------------------------------
# ALB access logs S3 bucket
# --------------------------------------------------

module "traefik_alb_s3_access_logs" {
  source          = "../../_sub/storage/s3-bucket-lifecycle"
  name            = local.alb_access_log_bucket_name
  retention_days  = var.traefik_alb_s3_access_logs_retiontion_days
  policy          = local.alb_access_log_bucket_policy
  additional_tags = var.s3_bucket_additional_tags
}

# --------------------------------------------------
# Load Balancers in front of Traefik
# --------------------------------------------------

module "traefik_blue_variant_flux_manifests" {
  source                  = "../../_sub/compute/k8s-traefik-flux"
  count                   = var.traefik_blue_variant_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  deploy_name             = "traefik-blue-variant"
  namespace               = "traefik-blue-variant"
  helm_chart_version      = var.traefik_blue_variant_helm_chart_version
  replicas                = length(data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids)
  http_nodeport           = var.traefik_blue_variant_http_nodeport
  admin_nodeport          = var.traefik_blue_variant_admin_nodeport
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  additional_args         = var.traefik_blue_variant_additional_args
  dashboard_ingress_host  = "traefik-blue-variant.${var.eks_cluster_name}.${var.workload_dns_zone_name}"
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# TODO(samdi): Rename to traefik_green_variant_manifests so it is consistent with the b/g traefik naming
module "traefik_variant_flux_manifests" {
  source                  = "../../_sub/compute/k8s-traefik-flux"
  count                   = var.traefik_green_variant_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  deploy_name             = "traefik-green-variant"
  namespace               = "traefik-green-variant"
  helm_chart_version      = var.traefik_green_variant_helm_chart_version
  replicas                = length(data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids)
  http_nodeport           = var.traefik_green_variant_http_nodeport
  admin_nodeport          = var.traefik_green_variant_admin_nodeport
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  additional_args         = var.traefik_green_variant_additional_args
  dashboard_ingress_host  = "traefik-green-variant.${var.eks_cluster_name}.${var.workload_dns_zone_name}"
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

module "traefik_alb_cert" {
  source              = "../../_sub/network/acm-certificate-san"
  deploy              = var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy ? true : false
  domain_name         = "*.${local.eks_fqdn}"
  dns_zone_name       = var.workload_dns_zone_name
  core_alias          = concat(var.traefik_alb_auth_core_alias, var.traefik_alb_anon_core_alias)
  aws_region          = var.aws_region          # Workaround to https://github.com/hashicorp/terraform/issues/21416
  aws_assume_role_arn = var.aws_assume_role_arn # Workaround to https://github.com/hashicorp/terraform/issues/21416
}

module "traefik_alb_auth_appreg" {
  source          = "../../_sub/security/azure-app-registration"
  count           = var.traefik_alb_auth_deploy ? 1 : 0
  name            = "Kubernetes EKS ${local.eks_fqdn} cluster"
  identifier_uris = ["https://${local.eks_fqdn}"]
  homepage_url    = "https://${local.eks_fqdn}"
  redirect_uris   = local.traefik_alb_auth_appreg_reply_urls
}

module "traefik_alb_auth" {
  source                = "../../_sub/compute/eks-alb-auth"
  name                  = "${var.eks_cluster_name}-traefik-alb-auth"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  azure_tenant_id       = try(module.traefik_alb_auth_appreg[0].tenant_id, "")
  azure_client_id       = try(module.traefik_alb_auth_appreg[0].application_id, "")
  azure_client_secret   = try(module.traefik_alb_auth_appreg[0].application_key, "")
  access_logs_bucket    = module.traefik_alb_s3_access_logs.name

  # Blue variant
  deploy_blue_variant            = var.traefik_alb_auth_deploy && var.traefik_blue_variant_deploy
  blue_variant_target_http_port  = var.traefik_blue_variant_http_nodeport
  blue_variant_target_admin_port = var.traefik_blue_variant_admin_nodeport
  blue_variant_health_check_path = "/ping"
  blue_variant_weight            = var.traefik_blue_variant_weight

  # Green variant
  deploy_green_variant            = var.traefik_alb_auth_deploy && var.traefik_green_variant_deploy
  green_variant_target_http_port  = var.traefik_green_variant_http_nodeport
  green_variant_target_admin_port = var.traefik_green_variant_admin_nodeport
  green_variant_health_check_path = "/ping"
  green_variant_weight            = var.traefik_green_variant_weight
}

module "traefik_alb_auth_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = (var.traefik_alb_auth_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy)) ? true : false
  zone_id      = local.workload_dns_zone_id
  record_name  = ["internal.${var.eks_cluster_name}.${var.workload_dns_zone_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}."
}

module "traefik_alb_auth_dns_for_traefik_blue_variant_dashboard" {
  source       = "../../_sub/network/route53-record"
  deploy       = (var.traefik_blue_variant_deploy && var.traefik_alb_auth_deploy) ? true : false
  zone_id      = local.workload_dns_zone_id
  record_name  = ["traefik-blue-variant.${var.eks_cluster_name}.${var.workload_dns_zone_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}."
}

module "traefik_alb_auth_dns_for_traefik_green_variant_dashboard" {
  source       = "../../_sub/network/route53-record"
  deploy       = (var.traefik_green_variant_deploy && var.traefik_alb_auth_deploy) ? true : false
  zone_id      = local.workload_dns_zone_id
  record_name  = ["traefik-green-variant.${var.eks_cluster_name}.${var.workload_dns_zone_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}."
}

module "traefik_alb_auth_dns_core_alias" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_auth_deploy ? length(var.traefik_alb_auth_core_alias) >= 1 : false
  zone_id      = local.core_dns_zone_id
  record_name  = var.traefik_alb_auth_core_alias
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}."

  providers = {
    aws = aws.core
  }
}

module "traefik_alb_anon" {
  source                = "../../_sub/compute/eks-alb"
  name                  = "${var.eks_cluster_name}-traefik-alb"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  access_logs_bucket    = module.traefik_alb_s3_access_logs.name

  # Blue variant
  deploy_blue_variant            = var.traefik_alb_anon_deploy && var.traefik_blue_variant_deploy
  blue_variant_target_http_port  = var.traefik_blue_variant_http_nodeport
  blue_variant_target_admin_port = var.traefik_blue_variant_admin_nodeport
  blue_variant_health_check_path = "/ping"
  blue_variant_weight            = var.traefik_blue_variant_weight

  # Green variant
  deploy_green_variant            = var.traefik_alb_anon_deploy && var.traefik_green_variant_deploy
  green_variant_target_http_port  = var.traefik_green_variant_http_nodeport
  green_variant_target_admin_port = var.traefik_green_variant_admin_nodeport
  green_variant_health_check_path = "/ping"
  green_variant_weight            = var.traefik_green_variant_weight
}

module "traefik_alb_anon_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_anon_deploy
  zone_id      = local.workload_dns_zone_id
  record_name  = ["*.${var.eks_cluster_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = module.traefik_alb_anon.alb_fqdn
}

module "traefik_alb_anon_dns_core_alias" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_anon_deploy ? length(var.traefik_alb_anon_core_alias) >= 1 : false
  zone_id      = local.core_dns_zone_id
  record_name  = var.traefik_alb_anon_core_alias
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = module.traefik_alb_anon.alb_fqdn

  providers = {
    aws = aws.core
  }
}

# --------------------------------------------------
# AWS IAM roles
# --------------------------------------------------

module "aws_cloudwatch_grafana_reader_iam_role" {
  source               = "../../_sub/security/iam-role"
  count                = var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
  role_name            = local.grafana_iam_role_name
  role_description     = "Role for Grafana to read Cloudwatch metric"
  role_policy_name     = local.grafana_iam_role_name
  role_policy_document = data.aws_iam_policy_document.cloudwatch_metrics.json
  assume_role_policy   = data.aws_iam_policy_document.cloudwatch_metrics_trust.json
}

# --------------------------------------------------
# Blaster
# --------------------------------------------------

module "blaster_namespace" {
  source                   = "../../_sub/compute/k8s-blaster-namespace"
  deploy                   = var.blaster_deploy
  cluster_name             = var.eks_cluster_name
  namespace_labels         = var.blaster_namespace_labels
  blaster_configmap_bucket = data.terraform_remote_state.cluster.outputs.blaster_configmap_bucket
  oidc_issuer              = local.oidc_issuer
}


# --------------------------------------------------
# Cloudwatch alarms and alarm notifier (Slack)
# --------------------------------------------------

module "alarm_notifier" {
  source            = "../../_sub/monitoring/alarm-notifier/"
  deploy            = var.alarm_notifier_deploy
  name              = "eks-${var.eks_cluster_name}-cloudwatch-alarms"
  slack_webhook_url = var.slack_webhook_url
}

module "cloudwatch_alarm_alb_5XX_anon" {
  source         = "../../_sub/monitoring/cloudwatch-alarms/alb-5XX/"
  deploy         = var.cloudwatch_alarm_alb_5XX_deploy && var.traefik_alb_anon_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy)
  sns_topic_arn  = module.alarm_notifier.sns_arn
  alb_arn_suffix = module.traefik_alb_anon.alb_arn_suffix
}

module "cloudwatch_alarm_alb_5XX_auth" {
  source         = "../../_sub/monitoring/cloudwatch-alarms/alb-5XX/"
  deploy         = var.cloudwatch_alarm_alb_5XX_deploy && var.traefik_alb_auth_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy)
  sns_topic_arn  = module.alarm_notifier.sns_arn
  alb_arn_suffix = module.traefik_alb_auth.alb_arn_suffix
}

module "cloudwatch_alarm_alb_targets_health_anon_blue" {
  source                      = "../../_sub/monitoring/cloudwatch-alarms/alb-targets-health"
  deploy                      = var.cloudwatch_alarm_alb_targets_health_deploy && var.traefik_alb_anon_deploy && var.traefik_blue_variant_deploy
  sns_topic_arn               = module.alarm_notifier.sns_arn
  alb_arn_suffix              = module.traefik_alb_anon.alb_arn_suffix
  alb_arn_target_group_suffix = module.traefik_alb_anon.alb_target_group_arn_suffix_blue
}

module "cloudwatch_alarm_alb_targets_health_anon_green" {
  source                      = "../../_sub/monitoring/cloudwatch-alarms/alb-targets-health"
  deploy                      = var.cloudwatch_alarm_alb_targets_health_deploy && var.traefik_alb_anon_deploy && var.traefik_green_variant_deploy
  sns_topic_arn               = module.alarm_notifier.sns_arn
  alb_arn_suffix              = module.traefik_alb_anon.alb_arn_suffix
  alb_arn_target_group_suffix = module.traefik_alb_anon.alb_target_group_arn_suffix_green
}

module "cloudwatch_alarm_alb_targets_health_auth_blue" {
  source                      = "../../_sub/monitoring/cloudwatch-alarms/alb-targets-health"
  deploy                      = var.cloudwatch_alarm_alb_targets_health_deploy && var.traefik_alb_auth_deploy && var.traefik_blue_variant_deploy
  sns_topic_arn               = module.alarm_notifier.sns_arn
  alb_arn_suffix              = module.traefik_alb_auth.alb_arn_suffix
  alb_arn_target_group_suffix = module.traefik_alb_auth.alb_target_group_arn_suffix_blue
}

module "cloudwatch_alarm_alb_targets_health_auth_green" {
  source                      = "../../_sub/monitoring/cloudwatch-alarms/alb-targets-health"
  deploy                      = var.cloudwatch_alarm_alb_targets_health_deploy && var.traefik_alb_auth_deploy && var.traefik_green_variant_deploy
  sns_topic_arn               = module.alarm_notifier.sns_arn
  alb_arn_suffix              = module.traefik_alb_auth.alb_arn_suffix
  alb_arn_target_group_suffix = module.traefik_alb_auth.alb_target_group_arn_suffix_green
}

module "alarm_notifier_log_account" {
  source            = "../../_sub/monitoring/alarm-notifier/"
  deploy            = var.cloudwatch_alarm_log_anomaly_deploy
  name              = "eks-${var.eks_cluster_name}-cloudwatch-alarms"
  slack_webhook_url = var.slack_webhook_url

  providers = {
    aws = aws.logs
  }
}

module "cloudwatch_alarm_log_anomaly" {
  source        = "../../_sub/monitoring/cloudwatch-alarms/log-anomaly/"
  deploy        = var.cloudwatch_alarm_log_anomaly_deploy
  sns_topic_arn = module.alarm_notifier_log_account.sns_arn

  providers = {
    aws = aws.logs
  }
}

# --------------------------------------------------
# Monitoring namespace
# --------------------------------------------------

module "monitoring_namespace" {
  source           = "../../_sub/compute/k8s-namespace"
  count            = var.monitoring_namespace_deploy ? 1 : 0
  name             = local.monitoring_namespace_name
  namespace_labels = var.monitoring_namespace_labels

  # The monitoring namespace has resources that are provisioned and
  # deprovisioned from it via Flux. If Flux is removed before the monitoring
  # namespace, the monitoring namespace may be unable to terminated as it will
  # have resources left in it with Flux finalizers which cannot be finalized.

  depends_on = [module.platform_fluxcd]
}


# --------------------------------------------------
# Goldpinger
# --------------------------------------------------

module "monitoring_goldpinger" {
  source                 = "../../_sub/compute/helm-goldpinger"
  count                  = var.monitoring_goldpinger_deploy ? 1 : 0
  chart_version          = var.monitoring_goldpinger_chart_version
  priority_class         = var.monitoring_goldpinger_priority_class
  namespace              = module.monitoring_namespace[0].name
  servicemonitor_enabled = var.monitoring_kube_prometheus_stack_deploy

  depends_on = [module.monitoring_kube_prometheus_stack]
}


# --------------------------------------------------
# Kube-prometheus-stack
# --------------------------------------------------

module "monitoring_kube_prometheus_stack" {
  source                      = "../../_sub/compute/helm-kube-prometheus-stack"
  count                       = var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
  cluster_name                = var.eks_cluster_name
  chart_version               = var.monitoring_kube_prometheus_stack_chart_version
  namespace                   = module.monitoring_namespace[0].name
  priority_class              = var.monitoring_kube_prometheus_stack_priority_class
  grafana_admin_password      = var.monitoring_kube_prometheus_stack_grafana_admin_password
  grafana_ingress_path        = var.monitoring_kube_prometheus_stack_grafana_ingress_path
  grafana_host                = "grafana.${var.eks_cluster_name}.${var.workload_dns_zone_name}"
  grafana_notifier_name       = "${var.eks_cluster_name}-alerting"
  grafana_iam_role_arn        = local.grafana_iam_role_arn
  grafana_serviceaccount_name = var.monitoring_kube_prometheus_stack_grafana_serviceaccount_name
  grafana_storage_enabled     = var.monitoring_kube_prometheus_stack_grafana_storage_enabled
  grafana_storage_class       = var.monitoring_kube_prometheus_stack_grafana_storageclass
  grafana_storage_size        = var.monitoring_kube_prometheus_stack_grafana_storage_size
  grafana_azure_tenant_id     = var.monitoring_kube_prometheus_stack_azure_tenant_id != "" ? var.monitoring_kube_prometheus_stack_azure_tenant_id : var.atlantis_arm_tenant_id
  slack_webhook               = var.monitoring_kube_prometheus_stack_slack_webhook
  prometheus_storageclass     = var.monitoring_kube_prometheus_stack_prometheus_storageclass
  prometheus_storage_size     = var.monitoring_kube_prometheus_stack_prometheus_storage_size
  prometheus_retention        = var.monitoring_kube_prometheus_stack_prometheus_retention
  slack_channel               = var.monitoring_kube_prometheus_stack_slack_channel
  target_namespaces           = var.monitoring_kube_prometheus_stack_target_namespaces
  github_owner                = var.fluxcd_bootstrap_repo_owner
  repo_name                   = var.fluxcd_bootstrap_repo_name
  repo_branch                 = var.fluxcd_bootstrap_repo_branch
  prometheus_request_memory   = var.monitoring_kube_prometheus_stack_prometheus_request_memory
  prometheus_request_cpu      = var.monitoring_kube_prometheus_stack_prometheus_request_cpu
  prometheus_limit_memory     = var.monitoring_kube_prometheus_stack_prometheus_limit_memory
  prometheus_limit_cpu        = var.monitoring_kube_prometheus_stack_prometheus_limit_cpu
  query_log_file_enabled      = var.monitoring_kube_prometheus_stack_prometheus_query_log_file_enabled
  enable_features             = var.monitoring_kube_prometheus_stack_prometheus_enable_features
  overwrite_on_create         = var.fluxcd_bootstrap_overwrite_on_create
  tolerations                 = var.monitoring_tolerations
  affinity                    = var.monitoring_affinity

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}


# --------------------------------------------------
# Metrics-Server
# --------------------------------------------------

module "monitoring_metrics_server" {
  source             = "../../_sub/compute/helm-metrics-server"
  count              = var.monitoring_metrics_server_deploy && var.monitoring_namespace_deploy ? 1 : 0
  helm_chart_version = var.monitoring_metrics_server_chart_version
  helm_repo_url      = var.monitoring_metrics_server_repo_url
  namespace          = module.monitoring_namespace[0].name
  tolerations        = var.monitoring_tolerations
  affinity           = var.monitoring_affinity
}

# --------------------------------------------------
# Scrape Prometheus metrics for aws-node Daemonset
# --------------------------------------------------

module "aws_node_service" {
  source     = "../../_sub/monitoring/aws-node"
  count      = var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
  depends_on = [module.monitoring_kube_prometheus_stack]
}

# --------------------------------------------------
# Flux CD
# --------------------------------------------------

module "platform_fluxcd" {
  source                  = "../../_sub/compute/k8s-fluxcd"
  release_tag             = var.fluxcd_version
  repository_name         = var.fluxcd_bootstrap_repo_name
  branch                  = var.fluxcd_bootstrap_repo_branch
  github_owner            = var.fluxcd_bootstrap_repo_owner
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  cluster_name            = var.eks_cluster_name
  kubeconfig_path         = local.kubeconfig_path

  providers = {
    github = github.fluxcd
  }
}

# --------------------------------------------------
# Atlantis
# --------------------------------------------------

module "atlantis" {
  source                    = "../../_sub/compute/helm-atlantis"
  count                     = var.atlantis_deploy ? 1 : 0
  cluster_name              = var.eks_cluster_name
  namespace                 = var.atlantis_namespace
  namespace_labels          = var.atlantis_namespace_labels
  chart_version             = var.atlantis_chart_version
  atlantis_image            = var.atlantis_image
  atlantis_image_tag        = var.atlantis_image_tag
  atlantis_ingress          = var.atlantis_ingress
  storage_class             = var.atlantis_storage_class
  data_storage              = var.atlantis_data_storage
  resources_requests_cpu    = var.atlantis_resources_requests_cpu
  resources_requests_memory = var.atlantis_resources_requests_memory
  resources_limits_cpu      = var.atlantis_resources_limits_cpu
  resources_limits_memory   = var.atlantis_resources_limits_memory
  github_username           = var.atlantis_github_username
  github_token              = var.atlantis_github_token
  github_repositories       = var.atlantis_github_repositories
  webhook_url               = var.atlantis_ingress
  webhook_events            = var.atlantis_webhook_events

  environment_variables = {
    PRODUCTION_AWS_ACCESS_KEY_ID                                     = var.atlantis_aws_access_key
    PRODUCTION_AWS_SECRET_ACCESS_KEY                                 = var.atlantis_aws_secret
    PRODUCTION_TF_VAR_slack_webhook_url                              = var.slack_webhook_url
    PRODUCTION_TF_VAR_monitoring_kube_prometheus_stack_slack_webhook = var.monitoring_kube_prometheus_stack_slack_webhook
    STAGING_AWS_ACCESS_KEY_ID                                        = var.atlantis_staging_aws_access_key
    STAGING_AWS_SECRET_ACCESS_KEY                                    = var.atlantis_staging_aws_secret
    STAGING_TF_VAR_slack_webhook_url                                 = var.staging_slack_webhook_url
    STAGING_TF_VAR_monitoring_kube_prometheus_stack_slack_webhook    = var.monitoring_kube_prometheus_stack_staging_slack_webhook
    SHARED_ARM_TENANT_ID                                             = var.atlantis_arm_tenant_id
    SHARED_ARM_SUBSCRIPTION_ID                                       = var.atlantis_arm_subscription_id
    SHARED_ARM_CLIENT_ID                                             = var.atlantis_arm_client_id
    SHARED_ARM_CLIENT_SECRET                                         = var.atlantis_arm_client_secret
    SHARED_TF_VAR_monitoring_kube_prometheus_stack_azure_tenant_id   = var.monitoring_kube_prometheus_stack_azure_tenant_id
    SHARED_TF_VAR_fluxcd_bootstrap_repo_owner_token                  = var.fluxcd_bootstrap_repo_owner_token
    SHARED_TF_VAR_atlantis_github_token                              = var.atlantis_github_token
    PRODUCTION_PRIME_AWS_ACCESS_KEY_ID                               = var.prime_aws_access_key
    PRODUCTION_PRIME_AWS_SECRET_ACCESS_KEY                           = var.prime_aws_secret
    PRODUCTION_PREPRIME_AWS_ACCESS_KEY_ID                            = var.preprime_aws_access_key
    PRODUCTION_PREPRIME_AWS_SECRET_ACCESS_KEY                        = var.preprime_aws_secret
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_KAFKA_BROKER                    = var.aws_account_manifests_kafka_broker
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_KAFKA_USERNAME                  = var.aws_account_manifests_kafka_username
    PRODUCTION_AWS_ACCOUNT_MANIFESTS_KAFKA_PASSWORD                  = var.aws_account_manifests_kafka_password
  }

  providers = {
    github = github.atlantis
  }
}

module "atlantis_flux_manifests" {
  source                = "../../_sub/compute/k8s-atlantis-flux-config"
  count                 = var.atlantis_deploy ? 1 : 0
  namespace             = var.atlantis_namespace
  ingressroute_hostname = var.atlantis_ingress
  cluster_name          = var.eks_cluster_name
  repo_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name             = var.fluxcd_bootstrap_repo_name
  repo_branch           = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create   = var.fluxcd_bootstrap_overwrite_on_create

  depends_on = [module.atlantis, module.platform_fluxcd]

  providers = {
    github = github.fluxcd
  }
}

# --------------------------------------------------
# Crossplane
# --------------------------------------------------

module "crossplane" {
  source                            = "../../_sub/compute/helm-crossplane"
  release_name                      = var.crossplane_release_name
  count                             = var.crossplane_deploy ? 1 : 0
  namespace                         = var.crossplane_namespace
  namespace_labels                  = var.crossplane_namespace_labels
  chart_version                     = var.crossplane_chart_version
  recreate_pods                     = var.crossplane_recreate_pods
  force_update                      = var.crossplane_force_update
  devel                             = var.crossplane_devel
  crossplane_providers              = var.crossplane_providers
  crossplane_admin_service_accounts = var.crossplane_admin_service_accounts
  crossplane_edit_service_accounts  = var.crossplane_edit_service_accounts
  crossplane_view_service_accounts  = var.crossplane_view_service_accounts
  crossplane_metrics_enabled        = var.crossplane_metrics_enabled
  crossplane_aws_iam_role_name      = var.crossplane_aws_iam_role_name
  eks_openid_connect_provider_url   = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

module "crossplane_operator" {
  source              = "../../_sub/compute/k8s-crossplane-operator"
  count               = var.crossplane_operator_deploy ? 1 : 0
  deploy_name         = var.crossplane_operator_deploy_name
  helm_chart_version  = var.crossplane_operator_helm_chart_version
  namespace           = var.crossplane_namespace # Same namespace as for the crossplane module
  repo_owner          = var.fluxcd_bootstrap_repo_owner
  repo_name           = var.fluxcd_bootstrap_repo_name
  repo_branch         = var.fluxcd_bootstrap_repo_branch
  cluster_name        = var.eks_cluster_name
  overwrite_on_create = var.fluxcd_bootstrap_overwrite_on_create

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.crossplane, module.platform_fluxcd]
}

module "crossplane_configuration_package" {
  source              = "../../_sub/compute/k8s-crossplane-cfg-pkg"
  count               = var.crossplane_cfg_pkg_deploy ? 1 : 0
  name                = var.crossplane_cfg_pkg_name
  package             = var.crossplane_cfg_pkg_docker_image
  repo_owner          = var.fluxcd_bootstrap_repo_owner
  repo_name           = var.fluxcd_bootstrap_repo_name
  repo_branch         = var.fluxcd_bootstrap_repo_branch
  cluster_name        = var.eks_cluster_name
  overwrite_on_create = var.fluxcd_bootstrap_overwrite_on_create

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.crossplane, module.platform_fluxcd]
}

locals {
  crossplane_provider_images = [for provider in var.crossplane_providers : element(split(":", provider), 0)]
}

module "crossplane_provider_confluent_prereqs" {
  source       = "../../_sub/compute/k8s-crossplane-provider-confluent"
  count        = contains(local.crossplane_provider_images, "dfdsdk/provider-confluent") ? 1 : 0
  namespace    = var.crossplane_namespace
  email        = var.crossplane_provider_confluent_email
  password     = var.crossplane_provider_confluent_password
  repo_owner   = var.fluxcd_bootstrap_repo_owner
  repo_name    = var.fluxcd_bootstrap_repo_name
  repo_branch  = var.fluxcd_bootstrap_repo_branch
  cluster_name = var.eks_cluster_name

  confluent_environments       = var.crossplane_confluent_environments
  confluent_clusters           = var.crossplane_confluent_clusters
  confluent_clusters_endpoints = var.crossplane_confluent_clusters_endpoints

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.crossplane, module.platform_fluxcd]
}

# --------------------------------------------------
# Blackbox Exporter
# --------------------------------------------------

module "blackbox_exporter_flux_manifests" {
  source                  = "../../_sub/monitoring/blackbox-exporter"
  count                   = var.blackbox_exporter_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  helm_chart_version      = var.blackbox_exporter_helm_chart_version
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  monitoring_targets      = local.blackbox_exporter_monitoring_targets
  namespace               = module.monitoring_namespace[0].name
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.monitoring_kube_prometheus_stack, module.platform_fluxcd]
}

# --------------------------------------------------
# Helm Exporter
# --------------------------------------------------

module "helm_exporter_flux_manifests" {
  source                  = "../../_sub/monitoring/helm-exporter"
  count                   = var.helm_exporter_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  helm_chart_version      = var.helm_exporter_helm_chart_version
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  namespace               = module.monitoring_namespace[0].name
  target_namespaces       = var.helm_exporter_target_namespaces
  target_charts           = var.helm_exporter_target_charts
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.monitoring_kube_prometheus_stack, module.platform_fluxcd]
}

# --------------------------------------------------
# podinfo
# --------------------------------------------------

# It doesn't really make sense to force us to create different github variables
# for everything that is using Flux, so we should fallback to using the same values
# as flux is using.
module "podinfo_flux_manifests" {
  source              = "../../_sub/examples/podinfo"
  count               = var.podinfo_deploy ? 1 : 0
  cluster_name        = var.eks_cluster_name
  repo_name           = var.fluxcd_bootstrap_repo_name
  repo_branch         = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create = var.fluxcd_bootstrap_overwrite_on_create

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# fluentd-cloudwatch through Flux
# --------------------------------------------------

module "fluentd_cloudwatch_flux_manifests" {
  source                          = "../../_sub/monitoring/fluentd-cloudwatch"
  count                           = var.fluentd_cloudwatch_deploy ? 1 : 0
  cluster_name                    = var.eks_cluster_name
  aws_region                      = var.aws_region
  retention_in_days               = var.fluentd_cloudwatch_retention_in_days
  repo_name                       = var.fluxcd_bootstrap_repo_name
  repo_branch                     = var.fluxcd_bootstrap_repo_branch
  deploy_oidc_provider            = var.aws_assume_logs_role_arn == null || var.aws_assume_logs_role_arn == "" ? false : true # do not create extra oidc provider if external log account is provided
  eks_openid_connect_provider_url = local.oidc_issuer
  overwrite_on_create             = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url            = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch         = var.fluxcd_apps_repo_branch
  docker_image_name               = var.fluentd_cloudwatch_docker_image_name
  docker_image_tag                = var.fluentd_cloudwatch_docker_image_tag

  providers = {
    github = github.fluxcd
    aws    = aws.logs
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

module "velero_flux_manifests" {
  source                  = "../../_sub/storage/velero-flux"
  count                   = var.velero_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  role_arn                = var.velero_role_arn
  bucket_name             = var.velero_bucket_name
  cron_schedule           = var.velero_cron_schedule
  log_level               = var.velero_log_level
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  helm_chart_version      = var.velero_helm_chart_version
  image_tag               = var.velero_image_tag
  plugin_for_aws_version  = var.velero_plugin_for_aws_version
  plugin_for_csi_version  = var.velero_plugin_for_csi_version
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}


# --------------------------------------------------
# aws-subnet-exporter
# --------------------------------------------------

module "aws_subnet_exporter" {
  source         = "../../_sub/compute/k8s-subnet-exporter"
  count          = var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
  namespace_name = module.monitoring_namespace[0].name
  aws_account_id = var.aws_workload_account_id
  aws_region     = var.aws_region
  image_tag      = "0.3"
  oidc_issuer    = local.oidc_issuer
  cluster_name   = var.eks_cluster_name
  iam_role_name  = var.subnet_exporter_iam_role_name
  tolerations    = var.monitoring_tolerations
  affinity       = var.monitoring_affinity
}

# --------------------------------------------------
# kyverno
# --------------------------------------------------
module "kyverno" {
  source              = "../../_sub/compute/helm-kyverno"
  count               = var.kyverno_deploy ? 1 : 0
  chart_version       = var.kyverno_chart_version
  excluded_namespaces = ["traefik"]
  replicas            = var.kyverno_replicas
  namespace_labels    = var.kyverno_namespace_labels
}

# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

module "elb_inactivity_cleanup_anon" {
  count                = data.terraform_remote_state.cluster.outputs.eks_is_sandbox && !var.disable_inactivity_cleanup && var.traefik_alb_anon_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy) ? 1 : 0
  source               = "../../_sub/compute/elb-inactivity-cleanup"
  inactivity_alarm_arn = data.terraform_remote_state.cluster.outputs.eks_inactivity_alarm_arn
  elb_name             = module.traefik_alb_anon.alb_name
  elb_arn              = module.traefik_alb_anon.alb_arn
}

module "elb_inactivity_cleanup_auth" {
  count                = data.terraform_remote_state.cluster.outputs.eks_is_sandbox && !var.disable_inactivity_cleanup && var.traefik_alb_auth_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy) ? 1 : 0
  source               = "../../_sub/compute/elb-inactivity-cleanup"
  inactivity_alarm_arn = data.terraform_remote_state.cluster.outputs.eks_inactivity_alarm_arn
  elb_name             = module.traefik_alb_auth.alb_name
  elb_arn              = module.traefik_alb_auth.alb_arn
}

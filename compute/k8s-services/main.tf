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
  aws_assume_logs_role_arn = var.aws_assume_logs_role_arn != null ? var.aws_assume_logs_role_arn : var.aws_assume_role_arn
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
  token        = var.atlantis_github_token != null ? var.atlantis_github_token : null
  organization = var.atlantis_github_organization != null ? var.atlantis_github_organization : null
  owner        = var.atlantis_github_owner != null ? var.atlantis_github_owner : null
  alias        = "atlantis"
}

provider "github" {
  token = var.platform_fluxcd_github_token
  owner = var.platform_fluxcd_github_owner
  alias = "fluxcd"
}

provider "random" {
}

provider "azuread" {

}


# --------------------------------------------------
# AWS EBS CSI Driver (Helm Chart Installation)
# --------------------------------------------------

module "ebs_csi_driver" {
  source               = "../../_sub/compute/helm-ebs-csi-driver"
  count                = var.ebs_csi_driver_deploy ? 1 : 0
  chart_version        = var.ebs_csi_driver_chart_version
  cluster_name         = var.eks_cluster_name
  kiam_server_role_arn = module.kiam_deploy.server_role_arn
  kubeconfig_path      = local.kubeconfig_path
}

# --------------------------------------------------
# ALB access logs S3 bucket
# --------------------------------------------------

module "traefik_alb_s3_access_logs" {
  source         = "../../_sub/storage/s3-bucket-lifecycle"
  name           = local.alb_access_log_bucket_name
  retention_days = var.traefik_alb_s3_access_logs_retiontion_days
  policy         = local.alb_access_log_bucket_policy
}

# --------------------------------------------------
# Traefik / ALB
# --------------------------------------------------

module "traefik_deploy" {
  source                 = "../../_sub/compute/k8s-traefik"
  deploy                 = var.traefik_deploy
  image_version          = var.traefik_version
  priority_class         = "service-critical"
  deploy_name            = "traefik"
  cluster_name           = var.eks_cluster_name
  replicas               = length(data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids)
  http_nodeport          = var.traefik_http_nodeport
  admin_nodeport         = var.traefik_admin_nodeport
  dashboard_ingress_host = local.traefik_dashboard_ingress_host
  dashboard_deploy       = var.traefik_dashboard_deploy
}

module "traefik_alb_cert" {
  source              = "../../_sub/network/acm-certificate-san"
  deploy              = var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy || var.traefik_okta_deploy ? true : false
  domain_name         = "*.${local.eks_fqdn}"
  dns_zone_name       = var.workload_dns_zone_name
  core_alias          = concat(var.traefik_alb_auth_core_alias, var.traefik_alb_anon_core_alias, var.traefik_alb_okta_core_alias)
  aws_region          = var.aws_region          # Workaround to https://github.com/hashicorp/terraform/issues/21416
  aws_assume_role_arn = var.aws_assume_role_arn # Workaround to https://github.com/hashicorp/terraform/issues/21416
}

module "traefik_alb_auth_appreg" {
  source          = "../../_sub/security/azure-app-registration"
  count           = var.traefik_alb_auth_deploy ? 1 : 0
  name            = "Kubernetes EKS ${local.eks_fqdn} cluster"
  homepage        = "https://${local.eks_fqdn}"
  identifier_uris = ["https://${local.eks_fqdn}"]
  reply_urls      = local.traefik_alb_auth_appreg_reply_urls
}

module "traefik_alb_auth" {
  source                = "../../_sub/compute/eks-alb-auth"
  deploy                = var.traefik_alb_auth_deploy
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
  target_http_port      = var.traefik_http_nodeport
  target_admin_port     = var.traefik_admin_nodeport
  health_check_path     = var.traefik_health_check_path
  access_logs_bucket    = module.traefik_alb_s3_access_logs.name
}

module "traefik_alb_auth_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_auth_deploy
  zone_id      = local.workload_dns_zone_id
  record_name  = ["internal.${var.eks_cluster_name}"]
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
  record_value = "${element(concat(module.traefik_alb_auth_dns.record_name, [""]), 0)}.${var.workload_dns_zone_name}."

  providers = {
    aws = aws.core
  }
}

module "traefik_alb_anon" {
  source                = "../../_sub/compute/eks-alb"
  deploy                = var.traefik_alb_anon_deploy
  name                  = "${var.eks_cluster_name}-traefik-alb"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  target_http_port      = var.traefik_http_nodeport
  target_admin_port     = var.traefik_admin_nodeport
  health_check_path     = var.traefik_health_check_path
  access_logs_bucket    = module.traefik_alb_s3_access_logs.name
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
# KIAM
# --------------------------------------------------

module "kiam_deploy" {
  source                  = "../../_sub/compute/k8s-kiam"
  chart_version           = var.kiam_chart_version
  cluster_name            = var.eks_cluster_name
  priority_class          = "service-critical"
  aws_workload_account_id = var.aws_workload_account_id
  worker_role_id          = data.terraform_remote_state.cluster.outputs.eks_worker_role_id
  agent_deep_liveness     = true
  agent_liveness_timeout  = 5
  server_gateway_timeout  = "5s"
  servicemonitor_enabled  = var.monitoring_kube_prometheus_stack_deploy
  strict_mode_disabled    = var.kiam_strict_mode_disabled

  // Depends_on for servicemonitor is ignored if prometheus stack is not deployed but required otherwise
  depends_on = [module.monitoring_kube_prometheus_stack]
}


# --------------------------------------------------
# AWS IAM roles
# --------------------------------------------------

module "aws_cloudwatchlogs_iam_role" {
  source               = "../../_sub/security/iam-role"
  count                = var.cloudwatchlogs_iam_role_deploy ? 1 : 0
  role_name            = "eks-${var.eks_cluster_name}-cloudwatchlogs"
  role_description     = "Role for FluentD to assume in order to ship logs to CloudWatch Logs"
  role_policy_name     = "CloudWatchLogs"
  role_policy_document = jsonencode(local.cloudwatchlogs_policy)
  assume_role_policy   = jsonencode(local.cloudwatchlogs_assume_role_policy)

  providers = {
    aws = aws.logs
  }
}

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
# Namespaces
# --------------------------------------------------

# Annotate the kube-system namespace so that KIAM allows the traffic needed by the EBS CSI Driver
# This annotation is always applied.  The decision to allow this was taken on the basis that the annotation
# is a lightweight element with little cost.  If we wished to have it defined based on a feature toggle
# then it would create additional complexity and require that the toggle variable exist in two places,
# thus leading to confusion
locals {
  kubesystem_permitted_base_role = flatten([
    try(module.ebs_csi_driver[0].iam_role_name, []),
    try(module.aws_cloudwatchlogs_iam_role[0].arn, [])
  ])
  kubesystem_permitted_role_list        = concat(local.kubesystem_permitted_base_role, var.kubesystem_permitted_extra_roles)
  kubesystem_permitted_role_list_sorted = sort(local.kubesystem_permitted_role_list)
  kubesystem_permitted_role_string      = join("|", local.kubesystem_permitted_role_list_sorted)
}

module "kube_system_namespace" {
  source          = "../../_sub/compute/k8s-annotate-namespace"
  namespace       = "kube-system"
  kubeconfig_path = local.kubeconfig_path
  annotations     = { "iam.amazonaws.com/permitted" = local.kubesystem_permitted_role_string }
}


# --------------------------------------------------
# Blaster - depends on KIAM
# --------------------------------------------------

module "blaster_namespace" {
  source                   = "../../_sub/compute/k8s-blaster-namespace"
  deploy                   = var.blaster_deploy
  cluster_name             = var.eks_cluster_name
  blaster_configmap_bucket = data.terraform_remote_state.cluster.outputs.blaster_configmap_bucket
  kiam_server_role_arn     = module.kiam_deploy.server_role_arn
  extra_permitted_roles    = var.blaster_namespace_extra_permitted_roles
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

module "cloudwatch_alarm_alb_5XX" {
  source           = "../../_sub/monitoring/cloudwatch-alarms/alb-5XX/"
  deploy           = var.cloudwatch_alarm_alb_5XX_deploy
  sns_topic_arn    = module.alarm_notifier.sns_arn
  alb_arn_suffixes = concat(module.traefik_alb_anon.alb_arn_suffix, module.traefik_alb_auth.alb_arn_suffix)
}

module "cloudwatch_alarm_alb_targets_health" {
  source                        = "../../_sub/monitoring/cloudwatch-alarms/alb-targets-health"
  deploy                        = var.cloudwatch_alarm_alb_targets_health_deploy
  sns_topic_arn                 = module.alarm_notifier.sns_arn
  alb_target_group_arn_suffixes = concat(module.traefik_alb_anon.alb_target_group_arn_suffix, module.traefik_alb_auth.alb_target_group_arn_suffix)
  alb_arn_suffixes              = concat(module.traefik_alb_anon.alb_arn_suffix, module.traefik_alb_auth.alb_arn_suffix)
}


# --------------------------------------------------
# Monitoring namespace
# --------------------------------------------------

module "monitoring_namespace" {
  source    = "../../_sub/compute/k8s-namespace"
  count     = var.monitoring_namespace_deploy ? 1 : 0
  name      = "monitoring"
  iam_roles = local.monitoring_namespace_iam_roles
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
  source                          = "../../_sub/compute/helm-kube-prometheus-stack"
  count                           = var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
  cluster_name                    = var.eks_cluster_name
  chart_version                   = var.monitoring_kube_prometheus_stack_chart_version
  namespace                       = module.monitoring_namespace[0].name
  priority_class                  = var.monitoring_kube_prometheus_stack_priority_class
  grafana_admin_password          = var.monitoring_kube_prometheus_stack_grafana_admin_password
  grafana_ingress_path            = var.monitoring_kube_prometheus_stack_grafana_ingress_path
  grafana_host                    = "grafana.${var.eks_cluster_name}.${var.workload_dns_zone_name}"
  grafana_notifier_name           = "${var.eks_cluster_name}-alerting"
  grafana_iam_role_arn            = local.grafana_iam_role_arn # Coming from locals to avoid circular dependency between KIAM and Prometheus
  slack_webhook                   = var.monitoring_kube_prometheus_stack_slack_webhook
  prometheus_storageclass         = var.monitoring_kube_prometheus_stack_prometheus_storageclass
  prometheus_storage_size         = var.monitoring_kube_prometheus_stack_prometheus_storage_size
  prometheus_retention            = var.monitoring_kube_prometheus_stack_prometheus_retention
  slack_channel                   = var.monitoring_kube_prometheus_stack_slack_channel
  target_namespaces               = var.monitoring_kube_prometheus_stack_target_namespaces
  alertmanager_silence_namespaces = var.monitoring_alertmanager_silence_namespaces
}


# --------------------------------------------------
# Metrics-Server
# --------------------------------------------------

module "monitoring_metrics_server" {
  source        = "../../_sub/compute/helm-metrics-server"
  count         = var.monitoring_metrics_server_deploy && var.monitoring_namespace_deploy ? 1 : 0
  chart_version = var.monitoring_metrics_server_chart_version
  namespace     = module.monitoring_namespace[0].name
}


# --------------------------------------------------
# Flux CD
# --------------------------------------------------

module "platform_fluxcd" {
  source          = "../../_sub/compute/k8s-fluxcd"
  count           = var.platform_fluxcd_deploy ? 1 : 0
  release_tag     = var.platform_fluxcd_release_tag
  cluster_name    = var.eks_cluster_name
  repo_name       = var.platform_fluxcd_repo_name
  repo_path       = "./clusters/${var.eks_cluster_name}"
  github_owner    = var.platform_fluxcd_github_owner
  github_token    = var.platform_fluxcd_github_token
  kubeconfig_path = local.kubeconfig_path
  repo_branch     = var.platform_fluxcd_repo_branch

  providers = {
    github = github.fluxcd
  }
}

# --------------------------------------------------
# Atlantis
# --------------------------------------------------

module "atlantis" {
  source                       = "../../_sub/compute/helm-atlantis"
  count                        = var.atlantis_deploy ? 1 : 0
  namespace                    = var.atlantis_namespace
  chart_version                = var.atlantis_chart_version
  atlantis_image               = var.atlantis_image
  atlantis_image_tag           = var.atlantis_image_tag
  atlantis_ingress             = var.atlantis_ingress
  github_token                 = var.atlantis_github_token
  github_organization          = var.atlantis_github_organization
  github_username              = var.atlantis_github_username
  github_repositories          = var.atlantis_github_repositories
  webhook_url                  = var.atlantis_ingress
  webhook_events               = var.atlantis_webhook_events
  aws_access_key               = var.atlantis_aws_access_key
  aws_secret                   = var.atlantis_aws_secret
  access_key_master            = var.atlantis_access_key_master
  secret_key_master            = var.atlantis_secret_key_master
  arm_tenant_id                = var.atlantis_arm_tenant_id
  arm_subscription_id          = var.atlantis_arm_subscription_id
  arm_client_id                = var.atlantis_arm_client_id
  arm_client_secret            = var.atlantis_arm_client_secret
  platform_fluxcd_github_token = var.atlantis_platform_fluxcd_github_token
  storage_class                = var.atlantis_storage_class

  providers = {
    github = github.atlantis
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
  chart_version                     = var.crossplane_chart_version
  recreate_pods                     = var.crossplane_recreate_pods
  force_update                      = var.crossplane_force_update
  crossplane_providers              = var.crossplane_providers
  crossplane_admin_service_accounts = var.crossplane_admin_service_accounts
  crossplane_edit_service_accounts  = var.crossplane_edit_service_accounts
  crossplane_view_service_accounts  = var.crossplane_view_service_accounts
  crossplane_metrics_enabled        = var.crossplane_metrics_enabled
}

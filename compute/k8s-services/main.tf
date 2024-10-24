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
  prune                   = var.fluxcd_prune

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
  prune                   = var.fluxcd_prune

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
  azure_client_id       = try(module.traefik_alb_auth_appreg[0].client_id, "")
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

module "goldpinger" {
  source                  = "../../_sub/monitoring/goldpinger"
  count                   = var.goldpinger_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  repo_owner              = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  namespace               = var.goldpinger_namespace
  chart_version           = var.goldpinger_chart_version
  priority_class          = var.goldpinger_priority_class

  depends_on = [module.grafana, module.grafana_agent_k8s_monitoring, module.platform_fluxcd]

  providers = {
    github = github.fluxcd
  }
}


# --------------------------------------------------
# Kube-prometheus-stack
# --------------------------------------------------

module "monitoring_kube_prometheus_stack" {
  source                                              = "../../_sub/compute/helm-kube-prometheus-stack"
  count                                               = var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
  cluster_name                                        = var.eks_cluster_name
  chart_version                                       = var.monitoring_kube_prometheus_stack_chart_version
  namespace                                           = module.monitoring_namespace[0].name
  priority_class                                      = var.monitoring_kube_prometheus_stack_priority_class
  grafana_admin_password                              = var.monitoring_kube_prometheus_stack_grafana_admin_password
  grafana_ingress_path                                = var.monitoring_kube_prometheus_stack_grafana_ingress_path
  grafana_host                                        = "grafana.${var.eks_cluster_name}.${var.workload_dns_zone_name}"
  grafana_notifier_name                               = "${var.eks_cluster_name}-alerting"
  grafana_iam_role_arn                                = local.grafana_iam_role_arn
  grafana_serviceaccount_name                         = var.monitoring_kube_prometheus_stack_grafana_serviceaccount_name
  grafana_storage_enabled                             = var.monitoring_kube_prometheus_stack_grafana_storage_enabled
  grafana_storage_class                               = var.monitoring_kube_prometheus_stack_grafana_storageclass
  grafana_storage_size                                = var.monitoring_kube_prometheus_stack_grafana_storage_size
  grafana_serve_from_sub_path                         = var.monitoring_kube_prometheus_stack_grafana_serve_from_sub_path
  grafana_azure_tenant_id                             = var.monitoring_kube_prometheus_stack_azure_tenant_id != "" ? var.monitoring_kube_prometheus_stack_azure_tenant_id : var.atlantis_arm_tenant_id
  slack_webhook                                       = var.monitoring_kube_prometheus_stack_slack_webhook
  prometheus_storageclass                             = var.monitoring_kube_prometheus_stack_prometheus_storageclass
  prometheus_storage_size                             = var.monitoring_kube_prometheus_stack_prometheus_storage_size
  prometheus_retention                                = var.monitoring_kube_prometheus_stack_prometheus_retention
  prometheus_confluent_metrics_scrape_enabled         = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_enabled
  prometheus_confluent_metrics_api_key                = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_key
  prometheus_confluent_metrics_api_secret             = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_secret
  prometheus_confluent_metrics_scrape_interval        = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_interval
  prometheus_confluent_metrics_scrape_timeout         = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_timeout
  prometheus_confluent_metrics_resource_kafka_id_list = var.monitoring_kube_prometheus_stack_prometheus_confluent_metrics_resource_kafka_id_list
  slack_channel                                       = var.monitoring_kube_prometheus_stack_slack_channel
  target_namespaces                                   = var.monitoring_kube_prometheus_stack_target_namespaces
  github_owner                                        = var.fluxcd_bootstrap_repo_owner
  repo_name                                           = var.fluxcd_bootstrap_repo_name
  repo_branch                                         = var.fluxcd_bootstrap_repo_branch
  prometheus_request_memory                           = var.monitoring_kube_prometheus_stack_prometheus_request_memory
  prometheus_request_cpu                              = var.monitoring_kube_prometheus_stack_prometheus_request_cpu
  prometheus_limit_memory                             = var.monitoring_kube_prometheus_stack_prometheus_limit_memory
  prometheus_limit_cpu                                = var.monitoring_kube_prometheus_stack_prometheus_limit_cpu
  query_log_file_enabled                              = var.monitoring_kube_prometheus_stack_prometheus_query_log_file_enabled
  enable_features                                     = var.monitoring_kube_prometheus_stack_prometheus_enable_features
  overwrite_on_create                                 = var.fluxcd_bootstrap_overwrite_on_create
  tolerations                                         = var.monitoring_tolerations
  affinity                                            = var.monitoring_affinity
  prune                                               = var.fluxcd_prune
  providers = {
    github = github.fluxcd
  }
  enable_prom_kube_stack_components = var.grafana_agent_deploy || var.grafana_deploy ? false : true
  depends_on                        = [module.platform_fluxcd]
}


# --------------------------------------------------
# Metrics-Server
# --------------------------------------------------

module "metrics_server" {
  source                  = "../../_sub/monitoring/metrics-server"
  count                   = var.metrics_server_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  repo_owner              = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  chart_version           = var.metrics_server_helm_chart_version

  depends_on = [module.platform_fluxcd]

  providers = {
    github = github.fluxcd
  }
}


# --------------------------------------------------
# Scrape Prometheus metrics for aws-node Daemonset
# --------------------------------------------------

module "aws_node_service" {
  source = "../../_sub/monitoring/aws-node"
  count  = var.grafana_agent_deploy || var.grafana_deploy || var.monitoring_kube_prometheus_stack_deploy ? 1 : 0
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
  prune                   = var.fluxcd_prune
  endpoint                = data.aws_eks_cluster.eks.endpoint
  token                   = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  enable_monitoring       = var.monitoring_kube_prometheus_stack_deploy || var.grafana_deploy ? true : false

  providers = {
    github = github.fluxcd
  }
}

# --------------------------------------------------
# Atlantis
# --------------------------------------------------

module "atlantis_deployment" {
  source                    = "../../_sub/compute/atlantis"
  count                     = var.atlantis_deploy ? 1 : 0
  aws_region                = local.aws_region
  chart_version             = var.atlantis_chart_version
  cluster_name              = var.eks_cluster_name
  enable_secret_volumes     = var.atlantis_add_secret_volumes
  github_repositories       = var.atlantis_github_repositories
  github_token              = var.atlantis_github_token
  github_username           = var.atlantis_github_username
  gitops_apps_repo_branch   = var.fluxcd_apps_repo_branch
  gitops_apps_repo_url      = local.fluxcd_apps_repo_url
  image                     = var.atlantis_image
  image_tag                 = var.atlantis_image_tag
  ingress_hostname          = var.atlantis_ingress
  oidc_issuer               = local.oidc_issuer
  overwrite_on_create       = var.fluxcd_bootstrap_overwrite_on_create
  prune                     = var.fluxcd_prune
  repo_branch               = var.fluxcd_bootstrap_repo_branch
  repo_name                 = var.fluxcd_bootstrap_repo_name
  repo_owner                = var.fluxcd_bootstrap_repo_owner
  resources_limits_cpu      = var.atlantis_resources_limits_cpu
  resources_limits_memory   = var.atlantis_resources_limits_memory
  resources_requests_cpu    = var.atlantis_resources_requests_cpu
  resources_requests_memory = var.atlantis_resources_requests_memory
  storage_class             = var.atlantis_storage_class
  storage_size              = var.atlantis_data_storage
  workload_account_id       = var.aws_workload_account_id

  depends_on = [module.platform_fluxcd]

  providers = {
    github = github.fluxcd
  }
}

module "atlantis_github_configuration" {
  source                = "../../_sub/security/atlantis-github-configuration"
  count                 = var.atlantis_deploy ? 1 : 0
  dashboard_password    = module.atlantis_deployment[0].dashboard_password
  enable_github_secrets = var.atlantis_enable_github_secrets
  environment           = var.atlantis_environment
  github_repositories   = var.atlantis_github_repositories
  ingress_hostname      = var.atlantis_ingress
  webhook_events        = var.atlantis_webhook_events
  webhook_secret        = module.atlantis_deployment[0].webhook_secret

  depends_on = [module.atlantis_deployment]

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
  namespace               = var.blackbox_exporter_namespace
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.grafana, module.grafana_agent_k8s_monitoring, module.platform_fluxcd]
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
  prune                   = var.fluxcd_prune

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
# External-Snapshotter adds support for snapshot.storage.k8s.io/v1
# https://github.com/kubernetes-csi/external-snapshotter/tree/master
# --------------------------------------------------

module "external_snapshotter" {
  source                  = "../../_sub/storage/external-snapshotter"
  cluster_name            = var.eks_cluster_name
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

module "velero" {
  source                  = "../../_sub/storage/velero"
  count                   = var.velero_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  bucket_arn              = var.velero_bucket_arn
  cron_schedule           = var.velero_cron_schedule
  log_level               = var.velero_log_level
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  helm_chart_version      = var.velero_helm_chart_version
  image_tag               = var.velero_image_tag
  plugin_for_aws_version  = var.velero_plugin_for_aws_version
  plugin_for_csi_version  = var.velero_plugin_for_csi_version
  snapshots_enabled       = var.velero_snapshots_enabled
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune
  namespace               = var.velero_namespace
  service_account         = var.velero_service_account
  oidc_issuer             = local.oidc_issuer
  workload_account_id     = var.aws_workload_account_id

  providers = {
    github = github.fluxcd
    aws    = aws
  }

  depends_on = [module.platform_fluxcd, module.external_snapshotter]
}


# --------------------------------------------------
# aws-subnet-exporter
# --------------------------------------------------

module "aws_subnet_exporter" {
  source         = "../../_sub/compute/k8s-subnet-exporter"
  count          = var.subnet_exporter_deploy ? 1 : 0
  namespace_name = var.grafana_agent_deploy || var.grafana_deploy ? var.grafana_agent_namespace : module.monitoring_namespace[0].name
  aws_account_id = var.aws_workload_account_id
  aws_region     = var.aws_region
  image_tag      = "0.3"
  oidc_issuer    = local.oidc_issuer
  cluster_name   = var.eks_cluster_name
  iam_role_name  = var.subnet_exporter_iam_role_name
  tolerations    = var.monitoring_tolerations
  affinity       = var.monitoring_affinity

  depends_on = [module.grafana, module.grafana_agent_k8s_monitoring]
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


# --------------------------------------------------
# Grafana Agent for Kubernetes monitoring
# --------------------------------------------------

module "grafana_agent_k8s_monitoring" {
  source                        = "../../_sub/monitoring/helm-grafana-agent"
  count                         = var.grafana_agent_deploy ? 1 : 0
  chart_version                 = var.grafana_agent_chart_version
  cluster_name                  = var.eks_cluster_name
  api_token                     = var.grafana_agent_api_token
  prometheus_url                = var.grafana_agent_prometheus_url
  prometheus_username           = var.grafana_agent_prometheus_username
  loki_url                      = var.grafana_agent_loki_url
  loki_username                 = var.grafana_agent_loki_username
  tempo_url                     = var.grafana_agent_tempo_url
  tempo_username                = var.grafana_agent_tempo_username
  traces_enabled                = var.grafana_agent_traces_enabled
  open_cost_enabled             = var.grafana_agent_open_cost_enabled
  agent_resource_memory_limit   = var.grafana_agent_resource_memory_limit
  agent_resource_memory_request = var.grafana_agent_resource_memory_request
  affinity                      = var.observability_affinity
  tolerations                   = var.observability_tolerations
  agent_replicas                = var.grafana_agent_replicas
  storage_enabled               = var.grafana_agent_storage_enabled
  storage_class                 = var.grafana_agent_storage_class
  storage_size                  = var.grafana_agent_storage_size
  priority_class                = var.monitoring_kube_prometheus_stack_priority_class
  namespace                     = var.grafana_agent_namespace
  timeout                       = var.grafana_agent_helm_install_timeout
}

module "grafana" {
  source = "../../_sub/monitoring/grafana"
  count  = var.grafana_deploy ? 1 : 0

  cluster_name                  = var.eks_cluster_name
  github_owner                  = var.fluxcd_bootstrap_repo_owner
  repo_name                     = var.fluxcd_bootstrap_repo_name
  repo_branch                   = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_branch       = var.fluxcd_apps_repo_branch
  gitops_apps_repo_url          = local.fluxcd_apps_repo_url
  chart_version                 = var.grafana_agent_chart_version
  api_token                     = var.grafana_agent_api_token
  prometheus_url                = var.grafana_agent_prometheus_url
  prometheus_username           = var.grafana_agent_prometheus_username
  loki_url                      = var.grafana_agent_loki_url
  loki_username                 = var.grafana_agent_loki_username
  tempo_url                     = var.grafana_agent_tempo_url
  tempo_username                = var.grafana_agent_tempo_username
  traces_enabled                = var.grafana_agent_traces_enabled
  open_cost_enabled             = var.grafana_agent_open_cost_enabled
  agent_resource_memory_limit   = var.grafana_agent_resource_memory_limit
  agent_resource_memory_request = var.grafana_agent_resource_memory_request
  affinity                      = var.observability_affinity
  tolerations                   = var.observability_tolerations
  agent_replicas                = var.grafana_agent_replicas
  storage_enabled               = var.grafana_agent_storage_enabled
  storage_class                 = var.grafana_agent_storage_class
  storage_size                  = var.grafana_agent_storage_size
  priority_class                = var.monitoring_kube_prometheus_stack_priority_class
  namespace                     = var.grafana_agent_namespace

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# External Secrets
# --------------------------------------------------

module "external_secrets" {
  source                  = "../../_sub/security/external-secrets"
  count                   = var.external_secrets_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  deploy_name             = "external-secrets"
  namespace               = "external-secrets"
  helm_chart_version      = var.external_secrets_helm_chart_version
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# External Secrets with SSM
# --------------------------------------------------

locals {
  aws_region = var.external_secrets_ssm_aws_region != "" ? var.external_secrets_ssm_aws_region : var.aws_region
}

module "external_secrets_ssm" {
  source              = "../../_sub/security/external-secrets-ssm"
  count               = var.external_secrets_deploy && var.external_secrets_ssm_deploy ? 1 : 0
  workload_account_id = var.aws_workload_account_id
  aws_region          = local.aws_region
  oidc_issuer         = local.oidc_issuer
  iam_role_name       = var.external_secrets_ssm_iam_role_name
  service_account     = var.external_secrets_ssm_service_account
  allowed_namespaces  = var.external_secrets_ssm_allowed_namespaces

  providers = {
    aws = aws
  }

  depends_on = [module.external_secrets]
}

# --------------------------------------------------
# kafka-exporter
# --------------------------------------------------

module "kafka_exporter" {
  source                  = "../../_sub/monitoring/kafka-exporter"
  count                   = var.kafka_exporter_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  deploy_name             = "kafka-exporter"
  namespace               = "monitoring"
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune
  kafka_clusters          = var.kafka_exporter_clusters

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# Nvidia device plugin
# --------------------------------------------------

module "eks_nvidia_device_plugin" {
  count                   = var.deploy_nvidia_device_plugin ? 1 : 0
  source                  = "../../_sub/compute/nvidia-device-plugin"
  repo_owner              = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  cluster_name            = var.eks_cluster_name
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  chart_version           = var.nvidia_chart_version
  namespace               = var.nvidia_namespace
  tolerations             = var.nvidia_device_plugin_tolerations
  affinity                = var.nvidia_device_plugin_affinity

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# Github ARC SS Controller
# --------------------------------------------------

module "github_arc_ss_controller" {
  source                  = "../../_sub/compute/github-arc-ss-controller"
  count                   = var.github_arc_ss_controller_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  deploy_name             = "arc"
  namespace               = "arc-systems"
  helm_chart_version      = var.github_arc_ss_controller_helm_chart_version
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# Github ARC Runners
# --------------------------------------------------

module "github_arc_runners" {
  source                  = "../../_sub/compute/github-arc-runners"
  count                   = var.github_arc_runners_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  deploy_name             = "arc-runner-set"
  namespace               = "arc-runners"
  helm_chart_version      = var.github_arc_runners_helm_chart_version
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create     = var.fluxcd_bootstrap_overwrite_on_create
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune
  github_config_url       = var.github_arc_runners_github_config_url
  github_config_secret    = var.github_arc_runners_github_config_secret
  runner_scale_set_name   = var.github_arc_runners_runner_scale_set_name
  storage_class_name      = var.github_arc_runners_storage_class_name
  storage_request_size    = var.github_arc_runners_storage_request_size
  min_runners             = var.github_arc_runners_min_runners
  max_runners             = var.github_arc_runners_max_runners

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd, module.github_arc_ss_controller]
}

# --------------------------------------------------
# Flux CD in a shared responsibility model with
# other platform teams
# --------------------------------------------------

module "shared_manifests" {
  source                       = "../../_sub/compute/k8s-shared-manifests"
  count                        = var.shared_manifests_deploy ? 1 : 0
  cluster_name                 = var.eks_cluster_name
  overlay_folder               = var.shared_manifests_overlay_folder
  repo_owner                   = var.fluxcd_bootstrap_repo_owner
  repo_name                    = var.fluxcd_bootstrap_repo_name
  repo_branch                  = var.fluxcd_bootstrap_repo_branch
  overwrite_on_create          = var.fluxcd_bootstrap_overwrite_on_create
  shared_manifests_repo_url    = local.shared_manifests_repo_url
  shared_manifests_repo_branch = var.shared_manifests_repo_branch
  shared_manifests_repo_name   = var.shared_manifests_repo_name

  providers = {
    github = github.fluxcd
  }

  depends_on = [
    module.platform_fluxcd
  ]
}

# --------------------------------------------------
# ALB access logs S3 bucket
# --------------------------------------------------

module "traefik_alb_s3_access_logs" {
  source         = "../../_sub/storage/s3-bucket-lifecycle"
  bucket_name    = local.alb_access_log_bucket_name
  retention_days = var.traefik_alb_s3_access_logs_retiontion_days
  bucket_policy  = local.alb_access_log_bucket_policy
  replication    = var.alb_access_logs_replication
  sse_algorithm  = var.alb_access_logs_sse_algorithm
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
  source               = "../../_sub/security/azure-app-registration"
  count                = var.traefik_alb_auth_deploy ? 1 : 0
  name                 = "Kubernetes EKS ${local.eks_fqdn} cluster"
  identifier_uris      = var.alb_az_app_registration_identifier_urls != null ? var.alb_az_app_registration_identifier_urls : ["https://${local.eks_fqdn}"]
  homepage_url         = "https://${local.eks_fqdn}"
  redirect_uris        = local.traefik_alb_auth_appreg_reply_urls
  additional_owner_ids = var.alb_az_app_registration_additional_owner_ids
}

module "traefik_alb_auth" {
  source                = "../../_sub/compute/eks-alb-auth"
  name                  = "${var.eks_cluster_name}-traefik-alb-auth"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = var.use_worker_nat_gateway ? data.terraform_remote_state.cluster.outputs.eks_control_subnet_ids : data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
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
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_control_subnet_ids
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

module "external_dns_iam_role_assume" {
  source               = "../../_sub/security/iam-role"
  count                = var.external_dns_deploy ? 1 : 0
  role_name            = local.external_dns_role_name
  role_description     = "Role for accessing Route53 hosted zone"
  role_policy_name     = local.external_dns_role_assume_policy_name
  role_policy_document = data.aws_iam_policy_document.external_dns_role_assume_policy.json
  assume_role_policy   = data.aws_iam_policy_document.external_dns_trust.json
}

module "external_dns_flux_manifests" {
  source                   = "../../_sub/network/external-dns"
  count                    = var.external_dns_deploy ? 1 : 0
  cluster_name             = var.eks_cluster_name
  deploy_name              = "external-dns"
  namespace                = "external-dns"
  helm_chart_version       = var.external_dns_helm_chart_version
  github_owner             = var.fluxcd_bootstrap_repo_owner
  repo_name                = var.fluxcd_bootstrap_repo_name
  repo_branch              = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url     = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch  = var.fluxcd_apps_repo_branch
  prune                    = var.fluxcd_prune
  cluster_region           = var.aws_region
  role_arn                 = module.external_dns_iam_role_assume[0].arn
  assume_role_arn          = var.external_dns_core_route53_assume_role_arn != "" ? var.external_dns_core_route53_assume_role_arn : module.external_dns_iam_role_route53_access[0].arn
  deletion_policy_override = var.external_deletion_policy_override
  domain_filters           = var.external_dns_domain_filters
  is_debug_mode            = var.external_dns_is_debug_mode
  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}


module "external_dns_iam_role_route53_access" {
  source               = "../../_sub/security/iam-role"
  count                = var.external_dns_deploy && var.external_dns_core_route53_assume_role_arn == "" ? 1 : 0
  role_name            = local.external_dns_role_name_cross_account
  role_description     = "Role for accessing Route53 hosted zones"
  role_policy_name     = local.external_dns_role_name_cross_account_assume_policy_name
  role_policy_document = data.aws_iam_policy_document.external_dns_core_route53_access_policy.json
  assume_role_policy   = data.aws_iam_policy_document.external_dns_core_route53_access_policy_trust.json
}

# --------------------------------------------------
# Blaster
# --------------------------------------------------

module "blaster_namespace" {
  source                   = "../../_sub/compute/k8s-blaster-namespace"
  deploy                   = var.blaster_deploy
  cluster_name             = var.eks_cluster_name
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
  name             = "monitoring"
  namespace_labels = { "pod-security.kubernetes.io/audit" = "baseline", "pod-security.kubernetes.io/enforce" = "privileged" }

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
  count                   = var.grafana_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  repo_owner              = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  chart_version           = var.goldpinger_chart_version

  depends_on = [module.grafana, module.platform_fluxcd]

  providers = {
    github = github.fluxcd
  }
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
  count  = var.grafana_deploy ? 1 : 0
}

# --------------------------------------------------
# Flux CD
# --------------------------------------------------

module "platform_fluxcd" {
  source                     = "../../_sub/compute/k8s-fluxcd"
  release_tag                = var.fluxcd_version
  repository_name            = var.fluxcd_bootstrap_repo_name
  branch                     = var.fluxcd_bootstrap_repo_branch
  github_owner               = var.fluxcd_bootstrap_repo_owner
  gitops_apps_repo_url       = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch    = var.fluxcd_apps_repo_branch
  cluster_name               = var.eks_cluster_name
  prune                      = var.fluxcd_prune
  endpoint                   = data.aws_eks_cluster.eks.endpoint
  token                      = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate     = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  enable_monitoring          = var.grafana_deploy ? true : false
  tenants                    = var.fluxcd_tenants
  source_controller_role_arn = var.fluxcd_source_controller_role_arn

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
  source              = "../../_sub/security/atlantis-github-configuration"
  count               = var.atlantis_deploy ? 1 : 0
  dashboard_password  = module.atlantis_deployment[0].dashboard_password
  github_repositories = sort(var.atlantis_github_repositories)
  ingress_hostname    = var.atlantis_ingress
  webhook_events      = var.atlantis_webhook_events
  webhook_secret      = module.atlantis_deployment[0].webhook_secret

  depends_on = [module.atlantis_deployment]

  providers = {
    github = github.atlantis
  }
}

# --------------------------------------------------
# Blackbox Exporter
# --------------------------------------------------

module "blackbox_exporter_flux_manifests" {
  source                  = "../../_sub/monitoring/blackbox-exporter"
  count                   = var.grafana_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  chart_version           = var.blackbox_exporter_helm_chart_version
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  monitoring_targets      = local.blackbox_exporter_monitoring_targets
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.grafana, module.platform_fluxcd]
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
  source                              = "../../_sub/storage/velero"
  count                               = var.velero_deploy ? 1 : 0
  cluster_name                        = var.eks_cluster_name
  bucket_arn                          = var.velero_bucket_arn
  cron_schedule                       = var.velero_cron_schedule
  log_level                           = var.velero_log_level
  repo_name                           = var.fluxcd_bootstrap_repo_name
  repo_branch                         = var.fluxcd_bootstrap_repo_branch
  helm_chart_version                  = var.velero_helm_chart_version
  image_tag                           = var.velero_image_tag
  plugin_for_aws_version              = var.velero_plugin_for_aws_version
  snapshots_enabled                   = var.velero_snapshots_enabled
  filesystem_backup_enabled           = var.velero_filesystem_backup_enabled
  gitops_apps_repo_url                = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch             = var.fluxcd_apps_repo_branch
  prune                               = var.fluxcd_prune
  namespace                           = var.velero_namespace
  service_account                     = var.velero_service_account
  oidc_issuer                         = local.oidc_issuer
  workload_account_id                 = var.aws_workload_account_id
  excluded_cluster_scoped_resources   = var.velero_excluded_cluster_scoped_resources
  excluded_namespace_scoped_resources = var.velero_excluded_namespace_scoped_resources
  read_only                           = var.velero_read_only
  ebs_csi_kms_arn                     = var.velero_ebs_csi_kms_arn

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
  count          = var.grafana_deploy ? 1 : 0
  namespace_name = var.grafana_deploy ? "grafana" : module.monitoring_namespace[0].name
  aws_account_id = var.aws_workload_account_id
  aws_region     = var.aws_region
  image_tag      = "0.3"
  oidc_issuer    = local.oidc_issuer
  cluster_name   = var.eks_cluster_name
  iam_role_name  = var.subnet_exporter_iam_role_name
  tolerations    = var.observability_tolerations
  affinity       = var.observability_affinity

  depends_on = [module.grafana]
}

# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

module "elb_inactivity_cleanup_anon" {
  count                = data.terraform_remote_state.cluster.outputs.eks_is_sandbox && local.enable_inactivity_cleanup && var.traefik_alb_anon_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy) ? 1 : 0
  source               = "../../_sub/compute/elb-inactivity-cleanup"
  inactivity_alarm_arn = data.terraform_remote_state.cluster.outputs.eks_inactivity_alarm_arn
  elb_name             = module.traefik_alb_anon.alb_name
  elb_arn              = module.traefik_alb_anon.alb_arn
}

module "elb_inactivity_cleanup_auth" {
  count                = data.terraform_remote_state.cluster.outputs.eks_is_sandbox && local.enable_inactivity_cleanup && var.traefik_alb_auth_deploy && (var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy) ? 1 : 0
  source               = "../../_sub/compute/elb-inactivity-cleanup"
  inactivity_alarm_arn = data.terraform_remote_state.cluster.outputs.eks_inactivity_alarm_arn
  elb_name             = module.traefik_alb_auth.alb_name
  elb_arn              = module.traefik_alb_auth.alb_arn
}


# --------------------------------------------------
# Grafana Agent for Kubernetes monitoring
# --------------------------------------------------

module "grafana" {
  source                        = "../../_sub/monitoring/grafana"
  count                         = var.grafana_deploy ? 1 : 0
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
  storage_size                  = var.grafana_agent_storage_size

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
  source         = "../../_sub/monitoring/kafka-exporter"
  count          = var.grafana_deploy ? 1 : 0
  cluster_name   = var.eks_cluster_name
  deploy_name    = "kafka-exporter"
  namespace      = "monitoring"
  github_owner   = var.fluxcd_bootstrap_repo_owner
  repo_name      = var.fluxcd_bootstrap_repo_name
  repo_branch    = var.fluxcd_bootstrap_repo_branch
  prune          = var.fluxcd_prune
  kafka_clusters = var.kafka_exporter_clusters

  providers = {
    github = github.fluxcd
  }

  depends_on = [module.platform_fluxcd]
}

# --------------------------------------------------
# 1password-connect
# --------------------------------------------------

module "onepassword_connect" {
  source                  = "../../_sub/security/helm-1password-connect"
  count                   = var.onepassword-connect_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  github_owner            = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch
  prune                   = var.fluxcd_prune
  workload_account_id     = var.aws_workload_account_id
  oidc_issuer             = local.oidc_issuer
  aws_region              = local.aws_region
  credentials_json        = var.onepassword_credentials_json
  token_for_atlantis      = var.onepassword_token_for_atlantis
  chart_version           = var.onepassword_connect_chart_version

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
# Apache Druid Operator
# --------------------------------------------------

module "druid_operator" {
  source                  = "../../_sub/compute/druid-operator"
  count                   = var.druid_operator_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  chart_version           = var.druid_operator_chart_version
  repo_owner              = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [
    module.platform_fluxcd
  ]
}

# --------------------------------------------------
# Trivy Operator
# --------------------------------------------------

module "trivy_operator" {
  source                         = "../../_sub/compute/trivy-operator"
  count                          = var.trivy_operator_deploy ? 1 : 0
  cluster_name                   = var.eks_cluster_name
  chart_version                  = var.trivy_operator_chart_version
  resources_requests_cpu         = var.trivy_operator_resources_requests_cpu
  resources_requests_memory      = var.trivy_operator_resources_requests_memory
  scan_resources_requests_cpu    = var.trivy_scan_resources_requests_cpu
  scan_resources_requests_memory = var.trivy_scan_resources_requests_memory
  github_token                   = var.fluxcd_bootstrap_repo_owner_token
  repo_owner                     = var.fluxcd_bootstrap_repo_owner
  repo_name                      = var.fluxcd_bootstrap_repo_name
  repo_branch                    = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url           = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch        = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [
    module.platform_fluxcd
  ]
}

# --------------------------------------------------
# Falco
# --------------------------------------------------

module "falco" {
  source                       = "../../_sub/security/falco"
  count                        = var.falco_deploy ? 1 : 0
  cluster_name                 = var.eks_cluster_name
  deploy_name                  = var.falco_deploy_name
  namespace                    = var.falco_namespace
  chart_version                = var.falco_chart_version
  repo_owner                   = var.fluxcd_bootstrap_repo_owner
  repo_name                    = var.fluxcd_bootstrap_repo_name
  repo_branch                  = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url         = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch      = var.fluxcd_apps_repo_branch
  slack_alert_webhook_url      = var.falco_slack_alert_webhook_url
  slack_alert_channel_name     = var.falco_slack_alert_channel_name
  slack_alert_minimum_priority = var.falco_slack_alert_minimum_priority
  stream_enabled               = var.falco_stream_enabled
  stream_webhook_url           = var.falco_stream_webhook_url
  stream_channel_name          = var.falco_stream_channel_name
  custom_rules                 = var.falco_custom_rules

  providers = {
    github = github.fluxcd
  }

  depends_on = [
    module.platform_fluxcd
  ]
}

# --------------------------------------------------
# Keda
# --------------------------------------------------

module "keda" {
  source                  = "../../_sub/compute/keda"
  count                   = var.keda_deploy ? 1 : 0
  cluster_name            = var.eks_cluster_name
  chart_version           = var.keda_chart_version
  repo_owner              = var.fluxcd_bootstrap_repo_owner
  repo_name               = var.fluxcd_bootstrap_repo_name
  repo_branch             = var.fluxcd_bootstrap_repo_branch
  gitops_apps_repo_url    = local.fluxcd_apps_repo_url
  gitops_apps_repo_branch = var.fluxcd_apps_repo_branch

  providers = {
    github = github.fluxcd
  }

  depends_on = [
    module.platform_fluxcd
  ]
}

# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    app_install_name = local.app_install_name
    helm_repo_path   = local.helm_repo_path
    deploy_name      = var.deploy_name
    namespace        = var.namespace
    prune            = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = var.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

resource "github_repository_file" "helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    namespace                    = var.namespace
    chart_version                = var.chart_version
    deploy_name                  = var.deploy_name
    slack_alert_webhook_url      = var.slack_alert_webhook_url
    slack_alert_channel_name     = var.slack_alert_channel_name
    slack_alert_minimum_priority = var.slack_alert_minimum_priority
    stream_enabled               = var.stream_enabled
    stream_webhook_url           = var.stream_webhook_url
    stream_channel_name          = var.stream_channel_name
    custom_rules                 = var.custom_rules
  })
  overwrite_on_create = true
}

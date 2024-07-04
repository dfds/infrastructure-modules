# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "nvidia_device_plugin_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    app_install_name = local.app_install_name
    helm_repo_path   = local.helm_repo_path
    prune            = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "nvidia_device_plugin_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "nvidia_device_plugin_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    namespace      = var.namespace
    chart_version  = var.chart_version
    deploy_name    = var.deploy_name
  })
  overwrite_on_create = var.overwrite_on_create
}

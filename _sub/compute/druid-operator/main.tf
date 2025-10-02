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
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = true
}

resource "github_repository_file" "helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    namespace                 = var.namespace
    chart_version             = var.chart_version
    deploy_name               = var.deploy_name
    watch_namespace           = var.watch_namespace
    resources_limits_cpu      = local.resources_limits_cpu
    resources_limits_memory   = local.resources_limits_memory
    resources_requests_cpu    = var.resources_requests_cpu
    resources_requests_memory = var.resources_requests_memory
  })
  overwrite_on_create = true
}

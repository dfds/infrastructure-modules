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
    prune            = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    deploy_name             = local.deploy_name
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    deploy_name               = local.deploy_name
    namespace                 = local.namespace
    chart_version             = var.chart_version
    enable_secret_volumes     = var.enable_secret_volumes
    image                     = var.image
    image_tag                 = var.image_tag
    ingress_hostname          = var.ingress_hostname
    org_allowlist             = join(",", local.fully_qualified_repository_names)
    parallel_pool_size        = var.parallel_pool_size
    resources_requests_cpu    = var.resources_requests_cpu
    resources_requests_memory = var.resources_requests_memory
    resources_limits_cpu      = local.resources_limits_cpu
    resources_limits_memory   = local.resources_limits_memory
    storage_class             = var.storage_class
    storage_size              = var.storage_size
    webhook_ingress_hostname  = var.webhook_ingress_hostname
  })
  overwrite_on_create = var.overwrite_on_create
}

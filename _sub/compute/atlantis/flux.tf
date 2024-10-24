# --------------------------------------------------
# Flux CD
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
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
    gitops_apps_repo_url    = var.gitops_apps_repo_url
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    basic_auth_password       = random_password.password.result
    chart_version             = var.chart_version
    deploy_name               = local.deploy_name
    enable_secret_volumes     = var.enable_secret_volumes
    github_secret             = random_password.webhook.result
    github_token              = var.github_token
    github_username           = var.github_username
    iam_role_name             = local.iam_role_name
    image                     = var.image
    image_tag                 = var.image_tag
    ingress_hostname          = var.ingress_hostname
    namespace                 = local.namespace
    org_allowlist             = join(",", local.fully_qualified_repository_names)
    parallel_pool_size        = var.parallel_pool_size
    resources_limits_cpu      = local.resources_limits_cpu
    resources_limits_memory   = local.resources_limits_memory
    resources_requests_cpu    = var.resources_requests_cpu
    resources_requests_memory = var.resources_requests_memory
    service_account_name      = local.service_account
    storage_class             = var.storage_class
    storage_size              = var.storage_size
    workload_account_id       = var.workload_account_id
  })
  overwrite_on_create = var.overwrite_on_create
}

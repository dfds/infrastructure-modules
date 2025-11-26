# --------------------------------------------------
# Flux CD
# --------------------------------------------------

resource "github_repository_file" "helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    deploy_name      = local.deploy_name
    app_install_name = local.app_install_name
    helm_repo_path   = local.helm_repo_path
    prune            = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    deploy_name          = local.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
    gitops_apps_repo_url = var.gitops_apps_repo_url
  })
  overwrite_on_create = true
}

resource "github_repository_file" "patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    basic_auth_password       = random_password.password.result
    chart_version             = var.chart_version
    deploy_name               = local.deploy_name
    github_secret             = random_password.webhook.result
    github_token              = var.github_token
    github_username           = var.github_username
    iam_role_name             = local.iam_role_name
    image_tag                 = var.image_tag
    ingress_hostname          = var.ingress_hostname
    org_allowlist             = join(",", local.fully_qualified_repository_names)
    resources_requests_cpu    = var.resources_requests_cpu
    resources_requests_memory = var.resources_requests_memory
    service_account_name      = local.service_account
    storage_size              = var.storage_size
    workload_account_id       = var.workload_account_id
  })
  overwrite_on_create = true
}

resource "github_repository_file" "kubeconfigs" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kubeconfigs.yaml"
  content = templatefile("${path.module}/values/kubeconfigs.yaml", {
    cluster_name = var.cluster_name
  })
  overwrite_on_create = true
}

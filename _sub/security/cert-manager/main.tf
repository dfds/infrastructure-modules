# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------


# --------------------------------------------------
# cert-manager-crd
# --------------------------------------------------

resource "github_repository_file" "certmanager_crd_path" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-crd.yaml"
  content = templatefile("${path.module}/values/crd.yaml", {
    deploy_name   = var.deploy_name
    crd_repo_path = local.crd_repo_path
    prune         = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "certmanager_crd_init" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.crd_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/crd-kustomization.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = var.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

# --------------------------------------------------
# cert-manager-helm
# --------------------------------------------------

resource "github_repository_file" "certmanager_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-helm.yaml", {
    app_install_name = local.app_install_name
    deploy_name      = var.deploy_name
    namespace        = var.namespace
    helm_repo_path   = local.helm_repo_path
    prune            = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "certmanager_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/helm-install.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = var.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

resource "github_repository_file" "certmanager_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/helm-patch.yaml", {
    deploy_name        = var.deploy_name
    namespace          = var.namespace
    helm_chart_version = var.helm_chart_version
    region             = var.cluster_region
    # role_arn           = var.role_arn
    cluster            = var.cluster_name
    is_debug_mode      = var.is_debug_mode
    # assume_role_arn    = var.assume_role_arn
  })
  overwrite_on_create = true
}

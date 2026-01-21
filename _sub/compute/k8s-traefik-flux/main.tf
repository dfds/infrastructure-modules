# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "traefik_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-helm.yaml", {
    app_install_name = local.app_install_name
    deploy_name      = var.deploy_name
    helm_repo_path   = local.helm_repo_path
    eks_fqdn         = var.eks_fqdn
    prune            = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "traefik_helm_install" {
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

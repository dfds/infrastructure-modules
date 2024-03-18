data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}

locals {
  cluster_repo_path    = "clusters/${var.cluster_name}"
  crd_repo_path        = "platform-apps/${var.cluster_name}/${var.deploy_name}-crd"
  controller_repo_path = "platform-apps/${var.cluster_name}/${var.deploy_name}-controller"
  config_repo_path     = "platform-apps/${var.cluster_name}/${var.deploy_name}-config"
}

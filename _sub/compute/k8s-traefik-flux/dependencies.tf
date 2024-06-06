data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  config_repo_path    = "platform-apps/${var.cluster_name}/${var.deploy_name}/config"
  app_install_name    = "platform-apps-${var.deploy_name}"
}

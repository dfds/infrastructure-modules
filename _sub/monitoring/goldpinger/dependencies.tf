data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  deploy_name         = "goldpinger"
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${local.deploy_name}/helm"
  app_install_name    = "platform-apps-${local.deploy_name}"
}

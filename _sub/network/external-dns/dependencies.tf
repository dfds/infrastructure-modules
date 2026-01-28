data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

data "aws_caller_identity" "this" {
}


locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  deploy_name        = "external-dns"
  namespace          = "external-dns"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${local.deploy_name}/helm"
  app_install_name    = "platform-apps-${local.deploy_name}"
}

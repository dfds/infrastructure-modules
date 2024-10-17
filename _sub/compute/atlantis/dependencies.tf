data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

data "github_repository" "repo" {
  count     = length(var.github_repositories)
  full_name = var.github_repositories[count.index]
}

locals {
  deploy_name = "atlantis"
  namespace   = "atlantis"
  fully_qualified_repository_names = [
    for repo in var.github_repositories :
    "github.com/${repo}"
  ]
  resources_limits_memory = var.resources_limits_memory != null ? var.resources_limits_memory : var.resources_requests_memory
  resources_limits_cpu    = var.resources_limits_cpu != null ? var.resources_limits_cpu : var.resources_requests_cpu
  default_repo_branch     = data.github_repository.main.default_branch
  repo_branch             = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path       = "clusters/${var.cluster_name}"
  helm_repo_path          = "platform-apps/${var.cluster_name}/${local.deploy_name}/helm"
  app_install_name        = "platform-apps-${local.deploy_name}"
}

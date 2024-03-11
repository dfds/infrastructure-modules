data "github_repository" "flux_repo" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  deploy_name                             = "atlantis"
  default_repo_branch                     = data.github_repository.flux_repo.default_branch
  repo_branch                             = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path                       = "clusters/${var.cluster_name}"
  config_repo_path                        = "platform-apps/${var.cluster_name}/${local.deploy_name}/config"
  app_install_name                        = "platform-apps-${local.deploy_name}"
  ingressroute_name                       = local.deploy_name
  ingressroute_basic_auth_secret_name     = "${local.deploy_name}-basic-auth" #tfsec:ignore:general-secrets-sensitive-in-local
  ingressroute_basic_auth_middleware_name = "${local.deploy_name}-basic-auth"
}

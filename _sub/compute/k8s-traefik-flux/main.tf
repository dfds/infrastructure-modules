# This module depends on you using Flux CD 2, and have added https://github.com/dfds/platform-apps in your
# flux-system as instructed in https://github.com/dfds/platform-apps/blob/main/README.md

# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "traefik_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content    = jsonencode(local.app_helm_path)
}

resource "github_repository_file" "traefik_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content    = jsonencode(local.helm_install)
}

resource "github_repository_file" "traefik_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content    = jsonencode(local.helm_patch)
}

resource "github_repository_file" "traefik_config_path" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content    = jsonencode(local.app_config_path)
}

resource "github_repository_file" "traefik_config_dashboard_ingressroute" {
  count      = var.dashboard_deploy ? 1 : 0
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/ingressroute-dashboard.yaml"
  content    = jsonencode(local.config_dashboard_ingressroute)
}

resource "github_repository_file" "traefik_config_dashboard_secret" {
  count      = var.dashboard_deploy ? 1 : 0
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/secret-dashboard.yaml"
  content    = jsonencode(local.config_dashboard_secret)
}

resource "github_repository_file" "traefik_config_dashboard_middleware" {
  count      = var.dashboard_deploy ? 1 : 0
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/middleware-dashboard.yaml"
  content    = jsonencode(local.config_dashboard_middleware)
}

resource "github_repository_file" "traefik_config_init" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content    = jsonencode(local.config_init)
}

# --------------------------------------------------
# Generate random password and create a hash for it
# --------------------------------------------------

resource "random_password" "password" {
  count            = var.dashboard_deploy ? 1 : 0
  length           = 32
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "htpasswd_password" "hash" {
  count    = var.dashboard_deploy ? 1 : 0
  password = random_password.password[0].result
  salt     = substr(sha512(random_password.password[0].result), 0, 8)
}

# --------------------------------------------------
# Save password in AWS Parameter Store
# --------------------------------------------------
resource "aws_ssm_parameter" "param_traefik_dashboard" {
  count           = var.dashboard_deploy ? 1 : 0
  name            = "/eks/${var.cluster_name}/traefik-dashboard"
  description     = "Credentials for accessing the Traefik dashboard"
  type            = "SecureString"
  value           = jsonencode(
    {
      "Username" = var.dashboard_username
      "Password" = random_password.password[0].result
    }
  )
  overwrite       = true
  tags = {
    createdBy = var.ssm_param_createdby != null ? var.ssm_param_createdby : "k8s-traefik-flux"
  }
}

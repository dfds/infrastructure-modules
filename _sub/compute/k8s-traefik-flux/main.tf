# This module depends on you using Flux CD 2, and have added https://github.com/dfds/platform-apps in your
# flux-system as instructed in https://github.com/dfds/platform-apps/blob/main/README.md
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
  count      = var.fallback_enabled ? 1 : 0
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content    = jsonencode(local.app_config_path)
}

resource "github_repository_file" "traefik_config_fallback_ingressroute" {
  count       = var.fallback_enabled ? 1 : 0
  repository  = var.repo_name
  branch      = local.repo_branch
  file        = "${local.config_repo_path}/ingressroute-fallback.yaml"
  content     = jsonencode(local.config_fallback_ingressroute)
}

resource "github_repository_file" "traefik_config_dashboard_ingressroute" {
  count       = var.dashboard_deploy ? 1 : 0
  repository  = var.repo_name
  branch      = local.repo_branch
  file        = "${local.config_repo_path}/ingressroute-dashboard.yaml"
  content     = jsonencode(local.config_dashboard_ingressroute)
}

resource "github_repository_file" "traefik_config_init" {
  count       = var.fallback_enabled ? 1 : 0 || var.dashboard_deploy ? 1 : 0
  repository  = var.repo_name
  branch      = local.repo_branch
  file        = "${local.config_repo_path}/kustomization.yaml"
  content     = jsonencode(local.config_init)
}

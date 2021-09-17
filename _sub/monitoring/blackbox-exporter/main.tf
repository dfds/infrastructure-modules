# This module depends on you using Flux CD 2, and have added https://github.com/dfds/platform-apps in your
# flux-system as instructed in https://github.com/dfds/platform-apps/blob/main/README.md

# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "blackbox_exporter_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content    = jsonencode(local.app_helm_path)
}

resource "github_repository_file" "blackbox_exporter_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content    = jsonencode(local.helm_install)
}

resource "github_repository_file" "blackbox_exporter_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content    = jsonencode(local.helm_patch)
}

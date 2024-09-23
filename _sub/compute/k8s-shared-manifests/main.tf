# --------------------------------------------------
# Flux CD in a shared responsibility model with
# other platform teams
# --------------------------------------------------

data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  overlay_folder      = var.is_sandbox ? "sandbox/${var.cluster_name}" : var.overlay_folder
}

resource "github_repository_file" "shared_manifests" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/shared-manifests.yaml"
  content = templatefile("${path.module}/values/shared-manifests.yaml", {
    shared_manifests_repo_url    = var.shared_manifests_repo_url
    shared_manifests_repo_branch = var.shared_manifests_repo_branch
    overlay_folder               = local.overlay_folder
    account_id                   = var.account_id
    role_name                    = var.role_name
    prune                        = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

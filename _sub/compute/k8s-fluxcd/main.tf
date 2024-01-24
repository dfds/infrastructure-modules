# --------------------------------------------------
# Flux CD Bootstrap
# --------------------------------------------------

resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

data "github_branch" "flux_branch" {
  repository = var.repository_name
  branch     = var.branch
}

resource "github_repository_deploy_key" "main" {
  title      = "flux-${var.cluster_name}-readonly"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = false
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.main]
  path       = local.cluster_target_path
  version    = var.release_tag
}


# --------------------------------------------------
# Flux CD Monitoring
# --------------------------------------------------

resource "github_repository_file" "flux_monitoring_config_path" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/${local.app_install_name}.yaml"
  content             = jsonencode(local.flux_monitoring)
  overwrite_on_create = var.overwrite_on_create
}


# --------------------------------------------------
# Flux CD Apps
# --------------------------------------------------

resource "github_repository_file" "platform_apps_init" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/platform-apps.yaml"
  content             = local.platform_apps_yaml
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "custom_kustomization" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/custom.yaml"
  content             = local.custom_kustomization_yaml
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "custom_folder" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "platform-apps/${var.cluster_name}/custom/README.md"
  content             = local.custom_folder_readme
  overwrite_on_create = var.overwrite_on_create
}
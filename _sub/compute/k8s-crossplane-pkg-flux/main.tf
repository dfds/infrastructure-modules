resource "github_repository_file" "crossplane_config_path" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content    = jsonencode(local.app_config_path)
}

resource "github_repository_file" "crossplane_config_init" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content    = jsonencode(local.config_init)
}

resource "github_repository_file" "crossplane_config_deployment" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/configuration.yaml"
  content    = jsonencode(local.config_deployment)
}

# --------------------------------------------------
# fluentd for cloudwatch
# --------------------------------------------------

resource "github_repository_file" "fluentd-cloudwatch_config_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content    = jsonencode(local.config_init)
}

resource "github_repository_file" "fluentd-cloudwatch_config_patch_yaml" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.config_repo_path}/patch.yaml"
  content    = local.config_patch_yaml
}

resource "github_repository_file" "fluentd-cloudwatch_config_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content    = jsonencode(local.app_config_path)
}

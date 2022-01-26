# --------------------------------------------------
# Demo app: podinfo
# --------------------------------------------------

resource "github_repository_file" "podinfo_config_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}.yaml"
  content    = jsonencode(local.app_config_path)
}

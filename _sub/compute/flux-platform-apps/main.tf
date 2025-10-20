resource "github_repository_file" "kustomization" {
  repository = var.repo_name
  branch     = var.repo_branch
  file       = "${local.kustomization_path}/platform-apps.yaml"
  content = templatefile("${path.module}/templates/platform-apps.yaml", {
    flux_platform_apps_url    = "ssh://git@github.com/${var.github_owner}/${var.github_repository}"
    flux_platform_apps_branch = var.github_branch
    flux_platform_apps_path   = "./apps/${var.overlay_path}"

    # Interface for flux kustomization postBuild substitutions
    flux_aws_account_id = var.aws_account_id
    flux_aws_region     = var.aws_region
    flux_cluster_name   = var.cluster_name
  })
  overwrite_on_create = true
}

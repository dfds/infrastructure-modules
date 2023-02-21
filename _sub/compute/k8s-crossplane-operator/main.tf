# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "crossplane_operator_helm" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = jsonencode(local.app_helm_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "crossplane_operator_helm_release" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/release.yaml"
  content             = jsonencode(local.helm_release)
  overwrite_on_create = var.overwrite_on_create
}

# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

resource "github_repository_file" "velero_flux_helm_path" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = jsonencode(local.app_helm_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_init" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = jsonencode(local.helm_init)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_patch_yaml" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.helm_repo_path}/patch.yaml"
  content             = local.helm_patch_yaml
  overwrite_on_create = var.overwrite_on_create
}

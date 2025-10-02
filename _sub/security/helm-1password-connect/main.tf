# --------------------------------------------------
# Create YAML files to be picked up by Flux CD
# --------------------------------------------------

resource "github_repository_file" "onepassword-connect_helm" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = local.app_helm_path
  overwrite_on_create = true
}

resource "github_repository_file" "onepassword-connect_helm_install" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = local.helm_install
  overwrite_on_create = true
}

resource "github_repository_file" "onepassword-connect_helm_patch" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/patch.yaml"
  content             = local.helm_patch
  overwrite_on_create = true
}

resource "aws_ssm_parameter" "onepassword_credentials_json" {
  #checkov:skip=CKV_AWS_337: Ensure SSM parameters are using KMS CMK
  name  = "/${var.deploy_name}/1password-credentials.json"
  type  = "SecureString"
  value = var.credentials_json
}

resource "aws_ssm_parameter" "atlantis" {
  #checkov:skip=CKV_AWS_337: Ensure SSM parameters are using KMS CMK
  count = var.token_for_atlantis != "" ? 1 : 0
  name  = "/atlantis/1password-connect-token"
  type  = "SecureString"
  value = var.token_for_atlantis
}

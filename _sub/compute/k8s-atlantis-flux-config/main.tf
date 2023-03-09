resource "github_repository_file" "atlantis_config_path" {
  repository          = var.flux_repo_name
  branch              = local.flux_repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content             = jsonencode(local.app_config_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "atlantis_config_init" {
  repository          = var.flux_repo_name
  branch              = local.flux_repo_branch
  file                = "${local.config_repo_path}/kustomization.yaml"
  content             = jsonencode(local.config_init)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "atlantis_config_ingressroute" {
  repository          = var.flux_repo_name
  branch              = local.flux_repo_branch
  file                = "${local.config_repo_path}/ingressroute-${local.deploy_name}.yaml"
  content             = jsonencode(local.config_ingressroute)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "atlantis_config_middleware" {
  repository          = var.flux_repo_name
  branch              = local.flux_repo_branch
  file                = "${local.config_repo_path}/middleware-${local.deploy_name}.yaml"
  content             = jsonencode(local.config_middleware)
  overwrite_on_create = var.overwrite_on_create
}

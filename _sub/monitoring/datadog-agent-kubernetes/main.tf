# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "datadog_provider_helm" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = jsonencode(local.app_helm_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "datadog_provider_helm_install" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = jsonencode(local.helm_install)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "datadog_provider_helm_patch" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/patch.yaml"
  content             = jsonencode(local.helm_patch)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "datadog_config_path" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content             = jsonencode(local.app_config_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "datadog_config_agent" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.config_repo_path}/agent.yaml"
  content             = local.config_agent
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "datadog_config_init" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.config_repo_path}/kustomization.yaml"
  content             = jsonencode(local.config_init)
  overwrite_on_create = var.overwrite_on_create
}
resource "github_repository_file" "atlantis_config_path" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    app_install_name = local.app_install_name
  })
  overwrite_on_create = var.overwrite_on_create
  config_repo_path    = local.config_repo_path
  prune               = var.prune
}

resource "github_repository_file" "atlantis_config_init" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    deploy_name = local.deploy_name
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "atlantis_config_ingressroute" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/ingressroute-${local.deploy_name}.yaml"
  content = templatefile("${path.module}/values/ingressroute.yaml", {
    ingressroute_name                       = local.ingressroute_name
    namespace                               = var.namespace
    ingressroute_hostname                   = var.ingressroute_hostname
    deploy_name                             = local.deploy_name
    ingressroute_basic_auth_middleware_name = local.ingressroute_basic_auth_middleware_name
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "atlantis_config_middleware" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/middleware-${local.deploy_name}.yaml"
  content = templatefile("${path.module}/values/middleware.yaml", {
    ingressroute_basic_auth_middleware_name = local.ingressroute_basic_auth_middleware_name
    namespace                               = var.namespace
    ingressroute_basic_auth_secret_name     = local.ingressroute_basic_auth_secret_name
  })
  overwrite_on_create = var.overwrite_on_create
}

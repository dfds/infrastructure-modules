# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "traefik_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-helm.yaml", {
    app_install_name = local.app_install_name
    deploy_name      = var.deploy_name
    namespace        = var.namespace
    helm_repo_path   = local.helm_repo_path
    prune            = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "traefik_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/helm-install.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "traefik_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/helm-patch.yaml", {
    deploy_name            = var.deploy_name
    namespace              = var.namespace
    helm_chart_version     = var.helm_chart_version
    http_nodeport          = var.http_nodeport
    admin_nodeport         = var.admin_nodeport
    additional_args        = concat(var.additional_args, var.certficate_resolver_args, local.ca_server_arg)
    replicas               = var.replicas
    dashboard_ingress_host = var.dashboard_ingress_host
    certificateResolverEnabled = var.enable_certificate_resolver
    certificateResolverEmail = var.certificate_resolver_email
    certificateResolverStorageEnabled = var.certificate_resolver_storage_enabled
    certificateResolverStorageClass = var.certificate_resolver_storage_class
    certificateResolverStorageAccessMode = var.certificate_resolver_storage_access_mode
    certificateResolverStorageSize = var.certificate_resolver_storage_size
  })
  overwrite_on_create = var.overwrite_on_create
}

# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "extdns_helm" {
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
  overwrite_on_create = true
}

resource "github_repository_file" "extdns_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/helm-install.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
    dns_records             = concat(var.dns_records_anon, var.dns_records_auth)
  })
  overwrite_on_create = true
}

resource "github_repository_file" "extdns_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/helm-patch.yaml", {
    deploy_name        = var.deploy_name
    namespace          = var.namespace
    helm_chart_version = var.helm_chart_version
    region             = var.cluster_region
    role_arn           = var.role_arn
    cluster            = var.cluster_name
    deletion_policy    = var.deletion_policy_override
    zone_ids           = var.zone_ids
    txt_owner_id       = local.txt_owner_id
    is_debug_mode      = var.is_debug_mode
    assume_role_arn    = var.assume_role_arn
  })
  overwrite_on_create = true
}

resource "github_repository_file" "record" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/dnsendpoints.yaml"
  content = templatefile("${path.module}/values/dnsendpoints.yaml", {
    deploy_name      = "${var.domain}-records"
    dns_records_anon = var.dns_records_anon
    dns_records_auth = var.dns_records_auth
    target_anon      = var.target_anon
    target_auth      = var.target_auth
  })
  overwrite_on_create = true
}
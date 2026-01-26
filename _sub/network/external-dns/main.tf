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
    region              = var.cluster_region
    core_zone_id     = var.zone_id_core
    workload_zone_id = var.zone_id_workload
    role_arn            = var.role_arn
    assume_role_arn = var.assume_role_arn
    txt_owner_id    = local.txt_owner_id
  })
  overwrite_on_create = true
}

resource "github_repository_file" "extdns_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/helm-install.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = var.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
    dns_records          = concat(var.dns_records_anon, var.dns_records_auth)
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

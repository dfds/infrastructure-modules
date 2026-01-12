# --------------------------------------------------
# Create files to be picked up by Flux CD
# --------------------------------------------------

resource "github_repository_file" "helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app.yaml", {
    app_install_name = local.app_install_name
    helm_repo_path   = local.helm_repo_path
    deploy_name      = local.deploy_name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = local.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

resource "github_repository_file" "policies" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-policies.yaml"
  content = templatefile("${path.module}/values/policies.yaml", {
    app_install_name   = local.app_install_name
    policies_repo_path = local.policies_repo_path
  })
  overwrite_on_create = true
}

resource "github_repository_file" "policies_kustomization" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.policies_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/policies-kustomization.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = local.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

resource "github_repository_file" "policy_reporter_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-policy-reporter-helm.yaml"
  content = templatefile("${path.module}/values/policy-reporter.yaml", {
    app_install_name    = local.app_install_name
    reporter_repo_path  = local.reporter_repo_path
    deploy_name         = local.deploy_name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "policy_reporter_kustomization" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.reporter_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/policy-reporter-kustomization.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = local.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

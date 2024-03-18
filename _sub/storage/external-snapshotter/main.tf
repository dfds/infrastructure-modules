# --------------------------------------------------
# External-Snapshotter adds support for snapshot.storage.k8s.io/v1
# https://github.com/kubernetes-csi/external-snapshotter/tree/master
#
# This is required to create EBS snapshots through Velero
# --------------------------------------------------


# --------------------------------------------------
# external-snapshotter-crd
# --------------------------------------------------

resource "github_repository_file" "external-snapshotter_crd_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${var.deploy_name}-crd.yaml"
  content = templatefile("${path.module}/values/crd.yaml", {
    deploy_name   = var.deploy_name
    crd_repo_path = local.crd_repo_path
    prune         = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-snapshotter_crd_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.crd_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/crd-kustomization.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}


# --------------------------------------------------
# external-snapshotter-controller
# --------------------------------------------------

resource "github_repository_file" "external-snapshotter_controller_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${var.deploy_name}-controller.yaml"
  content = templatefile("${path.module}/values/controller.yaml", {
    deploy_name          = var.deploy_name
    controller_repo_path = local.controller_repo_path
    prune                = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-snapshotter_controller_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.controller_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/controller-kustomization.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}


# --------------------------------------------------
# external-snapshotter-config
# --------------------------------------------------

resource "github_repository_file" "external-snapshotter_config_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${var.deploy_name}-config.yaml"
  content = templatefile("${path.module}/values/config.yaml", {
    deploy_name      = var.deploy_name
    config_repo_path = local.config_repo_path
    prune            = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-snapshotter_config_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/config-kustomization.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}

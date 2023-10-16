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
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_repo_path}/${var.deploy_name}-crd.yaml"
  content             = jsonencode(local.app_crd_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-snapshotter_crd_init" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.crd_repo_path}/kustomization.yaml"
  content             = jsonencode(local.crd_init)
  overwrite_on_create = var.overwrite_on_create
}


# --------------------------------------------------
# external-snapshotter-controller
# --------------------------------------------------

resource "github_repository_file" "external-snapshotter_controller_path" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_repo_path}/${var.deploy_name}-controller.yaml"
  content             = jsonencode(local.app_controller_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-snapshotter_controller_init" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.controller_repo_path}/kustomization.yaml"
  content             = jsonencode(local.controller_init)
  overwrite_on_create = var.overwrite_on_create
}


# --------------------------------------------------
# external-snapshotter-config
# --------------------------------------------------

resource "github_repository_file" "external-snapshotter_config_path" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_repo_path}/${var.deploy_name}-config.yaml"
  content             = jsonencode(local.app_config_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-snapshotter_config_init" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.config_repo_path}/kustomization.yaml"
  content             = jsonencode(local.config_init)
  overwrite_on_create = var.overwrite_on_create
}

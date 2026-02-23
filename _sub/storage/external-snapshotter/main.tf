# --------------------------------------------------
# External-Snapshotter adds support for snapshot.storage.k8s.io/v1
# https://github.com/kubernetes-csi/external-snapshotter/tree/master
#
# This is required to create EBS snapshots through Velero
# --------------------------------------------------

resource "github_repository_file" "external-snapshotter" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${local.deploy_name}.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    deploy_name = local.deploy_name
    deploy_path = local.deploy_path
    prune       = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "external-snapshotter_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.deploy_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = local.deploy_name
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

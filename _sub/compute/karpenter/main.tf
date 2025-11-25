locals {
  kustomization_path = "./platform-apps/${var.cluster_name}/karpenter"
}

resource "github_repository_file" "apps" {
  repository = var.repo_name
  branch     = var.repo_branch
  file       = "clusters/${var.cluster_name}/platform-apps-karpenter.yaml"
  content = templatefile("${path.module}/apps.yaml", {
    path    = local.kustomization_path
    cluster = var.cluster_name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "kustomization" {
  repository = var.repo_name
  branch     = var.repo_branch
  file       = "${local.kustomization_path}/kustomization.yaml"
  content = templatefile("${path.module}/kustomization.yaml", {
    apps_repo_url = var.apps_repo_url
    apps_repo_ref = var.apps_repo_ref
  })
  overwrite_on_create = true
}

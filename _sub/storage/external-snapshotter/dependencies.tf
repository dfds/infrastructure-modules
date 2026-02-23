data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}

locals {
  deploy_name       = "external-snapshotter"
  cluster_repo_path = "clusters/${var.cluster_name}"
  deploy_path       = "platform-apps/${var.cluster_name}/${local.deploy_name}"
}

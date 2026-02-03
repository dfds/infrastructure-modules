# --------------------------------------------------
# Github
# --------------------------------------------------

data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}

# --------------------------------------------------
# Velero
# --------------------------------------------------

# This is to support both buckets owned by the same AWS account or another account.
locals {
  bucket_name = split(":", var.bucket_arn)[5]
}

locals {
  deploy_name       = "velero"
  cluster_repo_path = "clusters/${var.cluster_name}"
  helm_repo_path    = "platform-apps/${var.cluster_name}/${local.deploy_name}/helm"
  app_install_name  = "platform-apps-${local.deploy_name}"
}

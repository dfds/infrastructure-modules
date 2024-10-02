# --------------------------------------------------
# Flux CD in a shared responsibility model with
# other platform teams
# --------------------------------------------------

data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}


locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "this" {
  title      = "Deployment key for ${var.cluster_name} cluster"
  repository = var.shared_manifests_repo_name
  key        = tls_private_key.this.public_key_openssh
  read_only  = false
}


#The known hosts entry is from https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
resource "kubernetes_secret" "this" {
  metadata {
    name      = "shared-manifests-git"
    namespace = "flux-system"
  }

  data = {
    identity       = tls_private_key.this.private_key_pem
    "identity.pub" = tls_private_key.this.public_key_openssh
    known_hosts    = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  }

  type = "Opaque"
}

resource "github_repository_file" "shared_manifests" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/shared-manifests.yaml"
  content = templatefile("${path.module}/values/shared-manifests.yaml", {
    shared_manifests_repo_url    = var.shared_manifests_repo_url
    shared_manifests_repo_branch = var.shared_manifests_repo_branch
    overlay_folder               = var.overlay_folder
    prune                        = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

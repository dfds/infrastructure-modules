# --------------------------------------------------
# Namespace
# --------------------------------------------------

locals {
  namespace = "flux-system"
}


# --------------------------------------------------
# Bootstrap Kubernetes manifests
# --------------------------------------------------

data "flux_install" "main" {
  target_path = var.repo_path
  version     = var.release_tag
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "flux_sync" "main" {
  target_path = var.repo_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.repo_name}.git"
  branch      = var.repo_branch
  namespace   = local.namespace
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}


# --------------------------------------------------
# Github
# --------------------------------------------------

locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}

# --------------------------------------------------
# Monitoring
# --------------------------------------------------

locals {
  cluster_repo_path   = "clusters/${var.cluster_name}"
  app_install_name    = "platform-apps-flux-monitoring"
  app_config_path     = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind" = "Kustomization"
    "metadata" = {
      "name" = local.app_install_name
      "namespace" = local.namespace
    }
    "spec" = {
      "dependsOn" = [
        {
          "name" = "platform-apps-sources"
        }
      ]
      "interval" = "1m0s"
      "path" = "./apps/flux-monitoring"
      "prune" = true
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "platform-apps-git"
      }
    }
  }
}

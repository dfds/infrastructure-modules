# --------------------------------------------------
# Namespace
# --------------------------------------------------

locals {
  namespace = "flux-system"
}

# --------------------------------------------------
# Github
# --------------------------------------------------

data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}

# --------------------------------------------------
# Monitoring
# --------------------------------------------------

locals {
  cluster_repo_path = "clusters/${var.cluster_name}"
  app_install_name  = "platform-apps-podinfo"
  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = local.app_install_name
      "namespace" = local.namespace
    }
    "spec" = {
      "dependsOn" = [
        {
          "name" = "platform-apps-sources"
        }
      ]
      "interval" = "1m0s"
      "path"     = "./apps/podinfo"
      "prune"    = true
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "platform-apps-git"
      }
    }
  }
}

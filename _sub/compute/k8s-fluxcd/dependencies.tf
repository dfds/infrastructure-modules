# --------------------------------------------------
# Local variables
# --------------------------------------------------

locals {
  cluster_target_path = "clusters/${var.cluster_name}"
  app_install_name    = "platform-apps-flux-monitoring"
}


# --------------------------------------------------
# Flux CD Monitoring
# --------------------------------------------------

locals {
  flux_monitoring = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = local.app_install_name
      "namespace" = "flux-system"
    }
    "spec" = {
      "dependsOn" = [
        {
          "name" = "platform-apps-sources"
        }
      ]
      "interval" = "1m0s"
      "path"     = "./apps/flux-monitoring"
      "prune"    = true
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "platform-apps-git"
      }
    }
  }
}

# --------------------------------------------------
# Flux CD Apps
# --------------------------------------------------

locals {

  platform_apps_yaml = <<YAML
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: platform-apps-git
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: ${var.gitops_apps_repo_branch}
  url: ${var.gitops_apps_repo_url}
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: platform-apps-sources
  namespace: flux-system
spec:
  interval: 1m0s
  dependsOn:
    - name: flux-system
  sourceRef:
    kind: GitRepository
    name: platform-apps-git
  path: ./sources
  prune: true
  YAML
}

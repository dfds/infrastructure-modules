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
      "prune"    = var.prune
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
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-apps-git
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: ${var.gitops_custom_apps_repo_branch}
  url: ${var.gitops_custom_apps_repo_url}
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
  prune: ${var.prune}
  YAML

  custom_kustomization_yaml = <<YAML
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: custom
  namespace: flux-system
spec:
  interval: 1m0s
  path: ./platform-apps/${var.cluster_name}/custom
  prune: ${var.prune}
  sourceRef:
    kind: GitRepository
    name: flux-system
  YAML

  custom_folder_readme = <<EOT
Place custom manifests in here. Make sure to place them in a folder named after the application
  EOT
}

  
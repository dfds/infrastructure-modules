data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch                   = data.github_repository.main.default_branch
  repo_branch                           = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path                     = "clusters/${var.cluster_name}"
  helm_repo_path                        = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  config_repo_path                      = "platform-apps/${var.cluster_name}/${var.deploy_name}/config"
  app_install_name                      = "platform-apps-${var.deploy_name}"

  app_helm_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta1"
    "kind" = "Kustomization"
    "metadata" = {
      "name" = "${local.app_install_name}-helm"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "dependsOn" = [
        {
          "name" = "platform-apps-sources"
        }
      ]
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path" = "./${local.helm_repo_path}"
      "prune" = true
      "validation" = "client"
    }
  }

  helm_install = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "https://github.com/dfds/platform-apps/apps/${var.deploy_name}"
    ]
    "patchesStrategicMerge" = [
      "patch.yaml"
    ]
  }

  helm_patch = {
    "apiVersion" = "helm.toolkit.fluxcd.io/v2beta1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "name"      = "prometheus-blackbox-exporter"
      "namespace" = var.namespace
    }
    "spec" = {
      "chart" = {
        "spec" = {
          "version" = var.helm_chart_version
        }
      }
      "values" = {
        "deployment" = {
          "replicas" = var.replicas
        }
        "serviceMonitor" = {
          "enabled" = true
          "defaults" = {
            "labels" = {
              "release" = "monitoring"
            }
          }
          "targets" = var.monitoring_targets
        }
      }
    }
  }
}

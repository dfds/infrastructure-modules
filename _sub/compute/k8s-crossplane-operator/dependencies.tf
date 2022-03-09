data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  app_install_name    = "platform-apps-${var.deploy_name}"

  app_helm_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${local.app_install_name}-helm"
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
      "path"  = "./${local.helm_repo_path}"
      "prune" = true
    }
  }

  helm_release = {
    "apiVersion" = "helm.toolkit.fluxcd.io/v2beta1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "name"      = var.deploy_name
      "namespace" = var.namespace
    }
    "spec" = {
      "releaseName" = "crossplane-operator-dfds"
      "chart" = {
        "spec" = {
          "chart"   = "crossplane-operator-dfds"
          "version" = var.helm_chart_version
          "sourceRef" = {
            "kind"      = "HelmRepository"
            "name"      = "dfds"
            "namespace" = "flux-system"
          }
        }
      }
      "values" = {
        "image" = {
          "tag" = var.image_tag
        }
      }
      "interval" = "1m0s"
      "install" = {
        "crds" = "CreateReplace"
        "remediation" = {
          "retries" = 3
        }
      }
      "upgrade" = {
        "crds" = "CreateReplace"
      }
    }
  }

  helm_install2 = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "https://github.com/dfds/platform-apps/apps/${var.deploy_name}"
    ]
  }
}

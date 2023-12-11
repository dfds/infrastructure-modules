data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  config_repo_path    = "platform-apps/${var.cluster_name}/${var.deploy_name}/config"
  app_install_name    = "platform-apps-${var.deploy_name}"
}

locals {
  app_helm_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
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
      "prune" = var.prune
    }
  }

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${local.app_install_name}-config"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "dependsOn" = [
        {
          "name" = "${local.app_install_name}-helm"
        }
      ]
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.config_repo_path}"
      "prune" = var.prune
    }
  }

  helm_install = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "${var.gitops_apps_repo_url}/apps/${var.deploy_name}?ref=${var.gitops_apps_repo_branch}"
    ]
    "patchesStrategicMerge" = [
      "patch.yaml"
    ]
  }

  helm_patch = {
    "apiVersion" = "helm.toolkit.fluxcd.io/v2beta1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "name"      = var.deploy_name
      "namespace" = var.namespace
    }
    "spec" = {
      "chart" = {
        "spec" = {
          "version" = var.helm_chart_version
        }
      }
      "values" = {
        "ports" = {
          "web" = {
            "nodePort" = var.http_nodeport
          }
          "traefik" = {
            "nodePort" = var.admin_nodeport
          }
        }
        "additionalArguments" = var.additional_args
        "deployment" = {
          "replicas" = var.replicas
        }
      }
    }
  }

  config_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "ingressroute-dashboard.yaml"
    ]
  }

  config_dashboard_ingressroute = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "${var.deploy_name}-dashboard"
      "namespace" = var.namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`${var.dashboard_ingress_host}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "services" = [
            {
              "kind" = "TraefikService"
              "name" = "api@internal"
            }
          ]
        }
      ]
    }
  }
}

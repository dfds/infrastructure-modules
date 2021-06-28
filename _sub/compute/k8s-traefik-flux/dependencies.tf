data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  base_repo_path      = "apps/${var.cluster_name}/${var.deploy_name}"
}

locals {
  kustomization = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "https://github.com/dfds/platform-apps/apps/traefik",
      "fallback.yaml"
    ]
    "patchesStrategicMerge" = [
      "patch.yaml"
    ]
  }

  patch = {
    "apiVersion" = "helm.toolkit.fluxcd.io/v2beta1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "name"      = var.deploy_name
      "namespace" = "traefik"
    }
    "spec" = {
      "values" = {
        "ports" = {
          "web" = {
            "nodePort" = var.http_nodeport
          }
          "websecure" = {
            "nodePort" = var.admin_nodeport
          }
        }
      }
    }
  }

  fallback = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "trafik-v1-fallback"
      "namespace" = "kube-system"
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes": [
      {
        "match": "HostRegexp(`{domain:.+}`)",
        "kind": "Rule",
        "priority": 2,
        "services": [
          {
            "name": "traefik",
            "port": 80
          }
        ]
      }
    ]
    }
  }
}

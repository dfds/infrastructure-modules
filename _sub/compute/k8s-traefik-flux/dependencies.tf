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
      "https://github.com/dfds/platform-apps/apps/traefik"
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
        "deployment" = {
          "replicas" = var.replicas
        }
      }
    }
  }

  fallback_manifest = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: "${var.fallback_ingressroute_name}"
  namespace: "${var.fallback_svc_namespace}"
spec:
  entryPoints:
  - web
  routes:
  - kind: Rule
    match: "${var.fallback_rule_match}"
    priority: ${var.fallback_ingressroute_priority}
    services:
    - kind: Service
      name: "${var.fallback_svc_name}"
      namespace: "${var.fallback_svc_namespace}"
      port: ${var.fallback_svc_port}
YAML
}

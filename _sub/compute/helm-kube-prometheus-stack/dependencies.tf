data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch        = data.github_repository.main.default_branch
  repo_branch                = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path          = "clusters/${var.cluster_name}"
  config_repo_path           = "platform-apps/${var.cluster_name}/grafana/config"
  grafana_platform_apps_name = "platform-apps-grafana"
  grafana_service_name       = "${var.namespace}-grafana"
  grafana_ingressroute_name  = "${var.namespace}-grafana"
  grafana_middleware_name    = "${local.grafana_ingressroute_name}-mw"
  grafana_alert_config_name  = "${var.namespace}-grafana-alert-config"

  grafana_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${local.grafana_platform_apps_name}-config"
      "namespace" = "flux-system"
    }
    "spec" = {
      "serviceAccountName" = "kustomize-controller"
      "interval"           = "1m0s"
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.config_repo_path}"
      "prune" = var.prune
    }
  }

  grafana_config_middleware = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = local.grafana_middleware_name
      "namespace" = var.namespace
    }
    "spec" = {
      "stripPrefix" = {
        "prefixes"   = [var.grafana_ingress_path]
        "forceSlash" = true
      }
    }
  }

  grafana_config_ingressroute = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = local.grafana_ingressroute_name
      "namespace" = var.namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`${var.grafana_host}`) && PathPrefix(`${var.grafana_ingress_path}`)"
          "services" = [
            {
              "kind"      = "Service"
              "name"      = local.grafana_service_name
              "namespace" = var.namespace
              "port"      = var.grafana_service_port
            }
          ]
          "middlewares" = [
            {
              "name"      = local.grafana_middleware_name
              "namespace" = var.namespace
            }
          ]
        }
      ]
    }
  }


  grafana_config_alert_config = {
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "labels" = {
        "grafana_alert" = "1"
      }
      "name"      = local.grafana_alert_config_name
      "namespace" = var.namespace
    }
    "data" = {
      "policies.yaml" = <<-EOT
      apiVersion: 1
      policies:
        - orgId: 1
          receiver: "${var.grafana_notifier_name}"
          group_wait: 30s
          group_interval: 5m
          continue: false
          group_by:
          - grafana_folder
          - alertname
          routes:
          - match:
            receiver: "${var.grafana_notifier_name}"
            group_wait: 30s
            group_interval: 5m
            object_matchers:
            - ['__contacts__', '=~', '.*"${var.grafana_notifier_name}".*']
          - match:
            receiver: "${var.grafana_notifier_name}"
            repeat_interval: 24h
            object_matchers:
            - ['repeat', '=', '24h']
      EOT
    }
  }

  grafana_config_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "ingressroute.yaml",
      "middleware.yaml",
      "alert-config.yaml"
    ]
  }
}

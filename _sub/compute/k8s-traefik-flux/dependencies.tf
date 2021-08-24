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
  dashboard_name                        = "${var.deploy_name}-external-dashboard"
  dashboard_basic_auth_data             = base64encode("${var.dashboard_username}:${htpasswd_password.hash[0].apr1}")
  dashboard_basic_auth_secret_name      = "${local.dashboard_name}-basic-auth"
  dashboard_basic_auth_middleware_name  = "${local.dashboard_name}-basic-auth"
  dashboard_middlewares = [
    {
      "name"      = local.dashboard_basic_auth_middleware_name
      "namespace" = var.namespace
    }
  ]
}

locals {
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

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta1"
    "kind" = "Kustomization"
    "metadata" = {
      "name" = "${local.app_install_name}-config"
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
      "path" = "./${local.config_repo_path}"
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
    "kind" = "Kustomization"
    "resources" = [
      "ingressroute-fallback.yaml",
      "ingressroute-dashboard.yaml",
      "secret-dashboard.yaml",
      "middleware-dashboard.yaml"
    ]
  }

  config_fallback_ingressroute = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = var.fallback_ingressroute_name
      "namespace" = var.namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = var.fallback_rule_match
          "priority" = var.fallback_ingressroute_priority
          "services" = [
            {
              "kind" = "Service"
              "name" = var.fallback_svc_name
              "namespace" = var.fallback_svc_namespace
              "port" = var.fallback_svc_port
            }
          ]
        }
      ]
    }
  }

  # The var.is_using_alb_auth ? []: local.dashboard_middlewares
  # turns on Basic Authentication in environments where trafik is not mentioned in the
  # DNS aliases in var.traefik_alb_auth_core_alias in the service configuration.
  config_dashboard_ingressroute = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = local.dashboard_name
      "namespace" = var.namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`${var.dashboard_ingress_host}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "services" = [
            {
              "kind" = "TraefikService"
              "name" = "api@internal"
            }
          ]
          "middlewares" = var.is_using_alb_auth ? [] : local.dashboard_middlewares
        }
      ]
    }
  }

  config_dashboard_secret = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "name" = local.dashboard_basic_auth_secret_name
      "namespace" = var.namespace
    }
    "data" = {
      "users" = local.dashboard_basic_auth_data
    }
  }

  config_dashboard_middleware = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = local.dashboard_basic_auth_middleware_name
      "namespace" = var.namespace
    }
    "spec" = {
      "basicAuth" = {
        "secret" = local.dashboard_basic_auth_secret_name
      }
    }
  }
}

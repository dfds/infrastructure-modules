data "github_repository" "flux_repo" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  deploy_name                             = "atlantis"
  default_repo_branch                     = data.github_repository.flux_repo.default_branch
  repo_branch                             = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path                       = "clusters/${var.cluster_name}"
  config_repo_path                        = "platform-apps/${var.cluster_name}/${local.deploy_name}/config"
  app_install_name                        = "platform-apps-${local.deploy_name}"
  ingressroute_name                       = local.deploy_name
  ingressroute_basic_auth_secret_name     = "${local.deploy_name}-basic-auth" #tfsec:ignore:general-secrets-sensitive-in-local
  ingressroute_basic_auth_middleware_name = "${local.deploy_name}-basic-auth"

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${local.app_install_name}-config"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.config_repo_path}"
      "prune" = true
    }
  }

  config_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "ingressroute-${local.deploy_name}.yaml",
      "middleware-${local.deploy_name}.yaml"
    ]
  }


  config_ingressroute = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = local.ingressroute_name
      "namespace" = var.namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`${var.ingressroute_hostname}`) && PathPrefix(`/`)"
          "services" = [
            {
              "kind" = "Service"
              "name" = local.deploy_name
              "port" = 80
            }
          ]
          "middlewares" = [
            {
              "name"      = local.ingressroute_basic_auth_middleware_name
              "namespace" = var.namespace
            }
          ]
        }
      ]
    }
  }

  config_middleware = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = local.ingressroute_basic_auth_middleware_name
      "namespace" = var.namespace
    }
    "spec" = {
      "basicAuth" = {
        "secret" = local.ingressroute_basic_auth_secret_name
      }
    }
  }
}

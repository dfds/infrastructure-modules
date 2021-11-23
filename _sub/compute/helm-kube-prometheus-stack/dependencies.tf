data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch       = data.github_repository.main.default_branch
  repo_branch               = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path         = "clusters/${var.cluster_name}"
  deploy_name               = "grafana"
  config_repo_path          = "platform-apps/${var.cluster_name}/${local.deploy_name}/config"
  app_install_name          = "platform-apps-${local.deploy_name}-ingressroute"
  ingressroute_name         = "${var.namespace}-${local.deploy_name}"
  middleware_name           = "${local.ingressroute_name}-mw"
  ingressroute_middlewares  = [
    {
      "name"      = local.middleware_name
      "namespace" = var.namespace
    }
  ]
}

config_middleware = {
  "apiVersion" = "traefik.containo.us/v1alpha1"
  "kind" = "Middleware"
  "metadata" = {
    "name" = local.middleware_name
    "namespace" = var.namespace
  }
  "spec" = {
    "stripPrefix" = {
      "prefixes" = [var.grafana_ingress_path]
    }
  }
}

config_ingressroute = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = local.ingressroute_name
      "namespace" = var.namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`${var.grafana_host}`) && (PathPrefix(`${var.grafana_ingress_path}`))"
          "services" = [
            {
              "kind" = "Service"
              "name" = "monitoring-grafana" # TODO
              "namespace" = var.namespace
              "port" = 80 #TODO
            }
          ]
          "middlewares" = local.ingressroute_middlewares
          "pritority" = 2
        }
      ]
    }
  }

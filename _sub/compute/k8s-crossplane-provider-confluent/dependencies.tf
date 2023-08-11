data "github_repository" "flux_repo" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  deploy_name         = "crossplane-provider-confluent"
  default_repo_branch = data.github_repository.flux_repo.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  config_repo_path    = "platform-apps/${var.cluster_name}/${local.deploy_name}/config"
  app_install_name    = "platform-apps-${local.deploy_name}"

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
      "prune" = var.prune
    }
  }

  config_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "configmap_environments.yaml",
      "configmap_clusters.yaml",
      "configmap_clusters_endpoints.yaml"
    ]
  }


  config_map_confluent_environments = {
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "name"      = "confluent-environment-id"
      "namespace" = var.namespace
    }
    "data" = var.confluent_environments
  }

  config_map_confluent_clusters = {
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "name"      = "confluent-cluster-id"
      "namespace" = var.namespace
    }
    "data" = var.confluent_clusters
  }

  config_map_confluent_clusters_endpoints = {
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "name"      = "confluent-clusters-endpoints"
      "namespace" = var.namespace
    }
    "data" = var.confluent_clusters_endpoints
  }
}

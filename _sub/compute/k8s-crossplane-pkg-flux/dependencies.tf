data "github_repository" "flux_repo" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  deploy_name         = "crossplane"
  default_repo_branch = data.github_repository.flux_repo.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  config_repo_path    = "platform-apps/${var.cluster_name}/${local.deploy_name}/config"
  app_install_name    = "platform-apps-${local.deploy_name}"

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
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
      "configuration.yaml"
    ]
  }

  config_deployment = {
    "apiVersion" = "pkg.crossplane.io/v1"
    "kind"       = "Configuration"
    "metadata" = {
      "name" = var.name
    }
    "spec" = {
      "package"                  = var.package
      "packagePullPolicy"        = var.package_pull_policy
      "revisionActivationPolicy" = var.revision_activation_policy
      "revisionHistoryLimit"     = var.revision_history_limit
    }
  }
}

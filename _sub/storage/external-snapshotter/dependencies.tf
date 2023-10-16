# --------------------------------------------------
# Github
# --------------------------------------------------

data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}


# --------------------------------------------------
# Common
# --------------------------------------------------

locals {
  cluster_repo_path = "clusters/${var.cluster_name}"
}


# --------------------------------------------------
# external-snapshotter-crd
# --------------------------------------------------

locals {
  crd_repo_path    = "platform-apps/${var.cluster_name}/${var.deploy_name}-crd"

  app_crd_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${var.deploy_name}-crd"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.crd_repo_path}"
      "prune" = var.prune
    }
  }

  crd_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "${var.gitops_apps_repo_url}/apps/${var.deploy_name}-crd?ref=${var.gitops_apps_repo_branch}"
    ]
  }
}


# --------------------------------------------------
# external-snapshotter-controller
# --------------------------------------------------

locals {
  controller_repo_path    = "platform-apps/${var.cluster_name}/${var.deploy_name}-controller"

  app_controller_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${var.deploy_name}-controller"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "dependsOn" = [{"name" = "${var.deploy_name}-crd"}]
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.controller_repo_path}"
      "prune" = var.prune
    }
  }

  controller_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "${var.gitops_apps_repo_url}/apps/${var.deploy_name}-controller?ref=${var.gitops_apps_repo_branch}"
    ]
  }
}


# --------------------------------------------------
# external-snapshotter-config
# --------------------------------------------------

locals {
  config_repo_path    = "platform-apps/${var.cluster_name}/${var.deploy_name}-config"

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${var.deploy_name}-config"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "dependsOn" = [{"name" = "${var.deploy_name}-controller"}]
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
      "${var.gitops_apps_repo_url}/apps/${var.deploy_name}-config?ref=${var.gitops_apps_repo_branch}"
    ]
  }
}

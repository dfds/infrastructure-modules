# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-helm.yaml", {
    app_install_name = local.app_install_name
    deploy_name      = var.deploy_name
    namespace        = local.namespace
    helm_repo_path   = local.helm_repo_path
    prune            = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/helm-install.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = true
}

resource "terraform_data" "aws-load-balancer-mutating-webhook-cleanup" {
  input = var.kubeconfig_path

  provisioner "local-exec" {
    environment = {
      K_CONFIG = self.input
    }
    when    = destroy
    command = "kubectl --kubeconfig=$K_CONFIG delete MutatingWebhookConfiguration aws-load-balancer-webhook --ignore-not-found=true"
  }
  depends_on = [ github_repository_file.helm_install ]
}

resource "terraform_data" "aws-load-balancer-validating-webhook-cleanup" {
  input = var.kubeconfig_path

  provisioner "local-exec" {
    environment = {
      K_CONFIG = self.input
    }
    when    = destroy
    command = "kubectl --kubeconfig=$K_CONFIG delete ValidatingWebhookConfiguration aws-load-balancer-webhook --ignore-not-found=true"
  }
  depends_on = [ github_repository_file.helm_install ]
}

resource "github_repository_file" "helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/helm-patch.yaml", {
    deploy_name        = var.deploy_name
    namespace          = local.namespace
    helm_chart_version = var.helm_chart_version
    region             = var.cluster_region
    role_arn           = var.role_arn
    cluster            = var.cluster_name
  })
  overwrite_on_create = true
}

# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-helm.yaml", {
    app_install_name = local.app_install_name
    deploy_name      = local.deploy_name
    namespace        = local.namespace
    helm_repo_path   = local.helm_repo_path
    region           = var.cluster_region
    role_arn         = var.role_arn
    cluster          = var.cluster_name
    prune            = true
  })
  overwrite_on_create = true
}

resource "github_repository_file" "helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/helm-install.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url
    deploy_name          = local.deploy_name
    namespace            = local.namespace
    gitops_apps_repo_ref = var.gitops_apps_repo_ref
  })
  overwrite_on_create = true
}

# ----------------------------------------------------------------------------------------------------
# On destroy there might be issue with deleting webhooks because of CRs not being removed in time
# This Terraform code can be a possible workaround to delete the webhooks on destroy
# ----------------------------------------------------------------------------------------------------

# resource "terraform_data" "aws-load-balancer-mutating-webhook-cleanup" {
#   input = var.kubeconfig_path

#   provisioner "local-exec" {
#     environment = {
#       K_CONFIG = self.input
#     }
#     when    = destroy
#     command = "kubectl --kubeconfig=$K_CONFIG delete MutatingWebhookConfiguration aws-load-balancer-webhook --ignore-not-found=true"
#   }
#   depends_on = [ github_repository_file.helm_install ]
# }

# resource "terraform_data" "aws-load-balancer-validating-webhook-cleanup" {
#   input = var.kubeconfig_path

#   provisioner "local-exec" {
#     environment = {
#       K_CONFIG = self.input
#     }
#     when    = destroy
#     command = "kubectl --kubeconfig=$K_CONFIG delete ValidatingWebhookConfiguration aws-load-balancer-webhook --ignore-not-found=true"
#   }
#   depends_on = [ github_repository_file.helm_install ]
# }
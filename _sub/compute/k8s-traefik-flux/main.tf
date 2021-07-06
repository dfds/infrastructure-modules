resource "github_repository_file" "traefik_kustomization" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.base_repo_path}/kustomization.yaml"
  content    = jsonencode(local.kustomization)
}

resource "github_repository_file" "traefik_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.base_repo_path}/patch.yaml"
  content    = jsonencode(local.patch)
}

resource "null_resource" "wait_for_traefik_dashboard_ingressroute" {

  depends_on = [github_repository_file.traefik_kustomization, github_repository_file.traefik_patch]
  provisioner "local-exec" {
    command = "timeout 10m until kubectl --kubeconfig ${var.kubeconfig_path} get ingressroute -n ${var.namespace} ${var.deploy_name}-dashboard; do sleep 10; done"
  }

}

resource "kubectl_manifest" "traefik_fallback" {
    count       = var.fallback ? 1 : 0
    yaml_body   = local.fallback_manifest
    depends_on  = [null_resource.wait_for_traefik_dashboard_ingressroute]
}

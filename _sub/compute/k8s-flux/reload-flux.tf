resource "null_resource" "restart-flux-pod" {
  count = var.deploy

  triggers = {
    git_private_key_changed = sha512(kubernetes_secret.flux-git-deploy[0].data.identity)
    docker_secret_changed = sha512(
      kubernetes_secret.docker-registry-creds[0].data[""].dockerconfigjson,
    )
  }

  provisioner "local-exec" {
    command = "kubectl -n ${var.namespace} delete po --selector=name=flux"

    environment = {
      KUBECONFIG = pathexpand("~/.kube/config_${var.cluster_name}")
    }
  }

  depends_on = [kubernetes_deployment.flux]
}


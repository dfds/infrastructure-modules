resource "null_resource" "restart-flux-pod" {
    triggers {
        private_key_changed = "${sha512(kubernetes_secret.flux.data.identity)}"
    }
  provisioner "local-exec" {
        command = "kubectl -n ${var.namespace} delete po --selector=name=flux"
        environment {
            KUBECONFIG =  "${pathexpand("~/.kube/config_${var.cluster_name}")}"
        }
  }
  depends_on = ["kubernetes_deployment.flux"]
}
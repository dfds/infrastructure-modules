resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} apply -f ${path.module}/system-public-info-viewer.yaml"
  }
}

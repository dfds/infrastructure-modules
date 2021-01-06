resource "null_resource" "annotate" {
  for_each = var.annotations
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} annotate ns ${var.namespace} ${each.key}='${each.value}' --overwrite"
  }

  triggers = {
    keys   = join(" ", keys(var.annotations))
    values = join(" ", values(var.annotations))
  }
}

variable "kubeconfig_path" {
  type    = string
  default = null
}

variable "namespace" {
  type        = string
  description = ""
}

variable "annotations" {
  type        = map
  description = ""
  default     = {}
}

# variable "annotations2" {
#   type        = string
#   description = ""
# }

resource "null_resource" "annotate" {
  for_each = var.annotations
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} annotate ns ${var.namespace} ${each.key}=${each.value} --overwrite"
  }

  triggers = {
    keys   = join(" ", keys(var.annotations))
    values = join(" ", values(var.annotations))
  }

}


# resource "null_resource" "annotate" {
#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig ${var.kubeconfig_path} annotate ns ${var.namespace} ${var.annotations2} --overwrite"
#   }

#   triggers = {
#     annotations2 = var.annotations2
#   }

# }

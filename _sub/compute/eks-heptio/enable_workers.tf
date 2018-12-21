resource "local_file" "kubeconfig" {
    content = "${local.kubeconfig}"
    filename = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
}

# resource "null_resource" "kubeconfig" {

#     provisioner "local-exec" {
#         command = "mkdir -p ${pathexpand("~/.kube")} && echo ${local.kubeconfig}>${pathexpand("~/.kube/config_${var.cluster_name}")}"
#     }
  
# }


resource "local_file" "enable-workers" {

    content = "${local.config-map-aws-auth}"
    filename = "${pathexpand("./.terraform/data/config-map-aws-auth_${var.cluster_name}.yaml")}"

    provisioner "local-exec" {
        command = "kubectl --kubeconfig ${local_file.kubeconfig.filename} apply -f ${pathexpand("./.terraform/data/config-map-aws-auth_${var.cluster_name}.yaml")}"
    }

    depends_on = ["local_file.kubeconfig"]
    # depends_on = ["null_resource.kubeconfig"]

}


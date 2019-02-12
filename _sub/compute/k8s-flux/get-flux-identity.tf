# resource "local_file" "get-flux-identity" {
#   count = "${var.deploy}"
#     content = "${var.cluster_name} "
#     filename = "${pathexpand("~/flux_public_ssh_${var.cluster_name}")}"

#     provisioner "local-exec" {
#         command = "fluxctl --k8s-fwd-ns=${var.namespace} identity >> ${pathexpand("~/flux_public_ssh_${var.cluster_name}")}"
#         environment {
#             USER = "root"
#             KUBECONFIG =  "${pathexpand("~/.kube/config_${var.cluster_name}")}"
#         }
#     }

#     # depends_on = ["kubernetes_deployment.flux"]    
#     depends_on = ["null_resource.restart-flux-container"]
    
# }

# data "local_file" "identity" {
#   count = "${var.deploy}"
#     filename = "${pathexpand("~/flux_public_ssh_${var.cluster_name}")}"
#     depends_on = ["local_file.get-flux-identity"]
# }
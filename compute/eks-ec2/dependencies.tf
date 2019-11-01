data "null_data_source" "paths" {

    inputs = {
        kubeconfig = "${pathexpand("~/.kube/config_${var.eks_cluster_name}")}"
    }

}

# locals {
#     # kubeconfig_path = "${pathexpand("~/.kube/config_${var.eks_cluster_name}")}"
#     # kubeconfig_path = "${path.root}/${var.eks_cluster_name}.config"
# }
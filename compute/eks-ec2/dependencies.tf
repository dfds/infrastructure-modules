locals {
    kubeconfig_path = "${pathexpand("~/.kube/config_${var.eks_cluster_name}")}"
}
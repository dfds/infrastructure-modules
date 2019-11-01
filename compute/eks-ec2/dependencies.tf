locals {
    # kubeconfig_path = "./${var.eks_cluster_name}.config"
    kubeconfig_path = "${pathexpand("~/.kube/${var.eks_cluster_name}.config")}"
}

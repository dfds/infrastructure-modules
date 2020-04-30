locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
}


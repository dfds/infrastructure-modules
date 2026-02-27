locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
}

locals {
  eks_route_table_tags = merge(var.tags, {
    "vpc.peering.actor" = "accepter"
  })
}

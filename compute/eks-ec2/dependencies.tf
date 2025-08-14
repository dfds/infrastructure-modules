locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
}

locals {
  eks_route_table_tags = merge(var.tags, {
    "vpc.peering.actor" = "accepter"
  })
}

# ------------------------------------------------------
# Inactivity based clean up and scale down for sandboxes
# ------------------------------------------------------

locals {
  enable_inactivity_cleanup = (
    var.enable_inactivity_cleanup && var.eks_is_sandbox ? true : false
  )
  enable_scale_to_zero_after_business_hours = (
    var.enable_scale_to_zero_after_business_hours && var.eks_is_sandbox ? true : false
  )
}

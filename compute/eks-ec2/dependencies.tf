locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
}

locals {
  eks_route_table_tags = merge(var.tags, {
    "vpc.peering.actor" = "accepter"
  })
}

locals {
  priority_class = [
    {
      "name"        = "service-critical"
      "description" = "Used for service critical pods, e.g. ingress controllers."
      "priority"    = 1000000
    },
    {
      "name"        = "cluster-monitoring"
      "description" = "Used for pods responsible for cluster-wide monitoring, alerting, and logging."
      "priority"    = 100000
    },
    {
      "name"        = "selfservice"
      "description" = "Used for pods necessary to support the DevEx self-service system."
      "priority"    = 10000
    },
    {
      "name"        = "high"
      "description" = "Used for production-grade workloads."
      "priority"    = 1000
    },
    {
      "name"        = "low"
      "description" = "The default priority class. Used for pods that are less important, e.g. dev and test pods."
      "priority"    = 10
      "default"     = true
    }
  ]
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

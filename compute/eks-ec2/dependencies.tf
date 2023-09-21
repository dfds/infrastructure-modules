locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
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

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster_name
}

locals {
  priority_classes = [
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
    }
  ]
  global_default = "low"
}

resource "kubernetes_priority_class" "class" {
  for_each = {for pc in local.priority_classes : pc.name => pc}
  metadata {
    name = each.value.name
  }

  description    = each.value.description
  value          = each.value.priority
  global_default = local.global_default == each.value.name
}

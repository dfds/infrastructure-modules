locals {
  priority_classes_v0 = [
    {
      name        = "selfservice"
      description = "DEPRECATED! Used for pods necessary to support the DevEx self-service system."
      priority    = 10000
    },
    {
      name        = "low" # this is the default priority class
      description = "The default priority class. Used for pods that are less important, e.g. dev and test pods."
      priority    = 10
    },
  ]
  priority_classes_v1 = [
    {
      name        = "cluster-infrastructure"
      description = "Used for pods that are very important for operations and can be moved to a different node."
      priority    = 3000000
    },
    {
      name        = "node-infrastructure"
      description = "Used for pods that are very important for operations and cannot be moved to a different node (like daemonsets)."
      priority    = 3001000
    },
    {
      name        = "cluster-observability"
      description = "Used for pods that are very important for observability, but not absolutely essential for the cluster to be operational and can be moved."
      priority    = 2000000
    },
    {
      name        = "node-observability"
      description = "Used for pods that are very important for observability, but not absolutely essential for the cluster to be operational and cannot be moved to a different node (like daemonsets)."
      priority    = 2001000
    },
  ]
  priority_classes = concat(local.priority_classes_v0, local.priority_classes_v1)
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

variable "priority_class" {
  type = list
  default = [
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
      "description" = "Used for pods that are less important, e.g. dev and test pods."
      "priority"    = 10
      "default"     = true
    },
  ]
}
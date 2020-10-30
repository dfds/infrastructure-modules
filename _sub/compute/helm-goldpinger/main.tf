resource "helm_release" "goldpinger" {
  count = var.deploy ? 1 : 0
  name = "goldpinger"
  chart = "stable/goldpinger"
  version = var.chart_version != null ? var.chart_version : null
  namespace = var.namespace

  set {
    name = "priorityClassName"
    value = var.priority_class
  }

  set {
    name = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "serviceMonitor.selector.release"
    value = "monitoring"
  }

}
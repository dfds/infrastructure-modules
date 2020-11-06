resource "helm_release" "goldpinger" {
  count = var.deploy ? 1 : 0
  name = "goldpinger"
  chart = "goldpinger"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  version = var.chart_version != null ? var.chart_version : null
  namespace = var.namespace
  recreate_pods = true
  create_namespace = true
  force_update = true

  set {
    name = "priorityClassName"
    value = var.priority_class
  }

  # set {
  #   name = "serviceMonitor.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "serviceMonitor.selector.release"
  #   value = "monitoring"
  # }

}
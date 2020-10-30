resource "helm_release" "goldpinger" {
  count = var.deploy ? 1 : 0
  name = "goldpinger"
  chart = "stable/goldpinger"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  version = var.chart_version
  namespace = var.namespace

  set {
    name = "priorityClassName"
    value = var.priority_class
  }

  set {
    name = "serviceMonitor.enabled"
    value = "true"
  }
}
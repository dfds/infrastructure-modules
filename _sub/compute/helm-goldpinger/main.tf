resource "helm_release" "goldpinger" {
  name          = "goldpinger"
  chart         = "goldpinger"
  repository    = "https://charts.helm.sh/stable"
  version       = var.chart_version
  namespace     = var.namespace
  recreate_pods = true
  force_update  = false

  set {
    name  = "priorityClassName"
    value = var.priority_class
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = var.servicemonitor_enabled
  }

  set {
    name  = "serviceMonitor.selector.release"
    value = "monitoring"
  }

  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "resources.requests.memory"
    value = "50Mi"
  }

  values = [
    file("${path.module}/tolerations.yaml")
  ]
}

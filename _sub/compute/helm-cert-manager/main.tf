resource "helm_release" "ce" {
  name          = "cert-manager"
  chart         = "cert-manager"
  repository    = "https://charts.jetstack.io"
  version       = var.chart_version
  namespace     = var.namespace
  recreate_pods = true
  force_update  = false
  create_namespace = true

  set {
    name  = "priorityClassName"
    value = var.priority_class
  }

  set {
    name = "installCRDs"
    value = true
  }

  set {
    name = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name = "resources.limits.cpu"
    value = "100m"
  }

  set {
    name = "resources.limits.memory"
    value = "128Mi"
  }

  set {
    name = "prometheus.servicemonitor.enabled"
    value = var.enable_servicemonitor
  }

  set {
    name = "prometheus.servicemonitor.labels.release"
    value = "monitoring"
  }
}

resource "helm_release" "metrics_server" {
  name          = "metrics-server"
  repository    = "https://charts.helm.sh/stable"
  chart         = "metrics-server"
  version       = var.chart_version
  namespace     = var.namespace
  recreate_pods = true

  values = [
    file("${path.module}/values/values.yaml")
  ]
}

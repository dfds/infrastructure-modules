resource "helm_release" "metrics_server" {
  name          = "metrics-server"
  repository    = var.helm_repo_url
  chart         = "metrics-server"
  version       = var.helm_chart_version
  namespace     = var.namespace
  recreate_pods = true

  values = [
    file("${path.module}/values/values.yaml")
  ]
}

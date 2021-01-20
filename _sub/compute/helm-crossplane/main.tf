resource "helm_release" "crossplane" {
    name = var.release_name
    chart = "crossplane"
    repository    = "https://charts.crossplane.io/stable"
    version       = var.chart_version != null ? var.chart_version : null
    namespace     = var.namespace
    recreate_pods = var.recreate_pods
    force_update  = var.force_update

    values = [
    templatefile("${path.module}/values/values.yaml", {
  })]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}
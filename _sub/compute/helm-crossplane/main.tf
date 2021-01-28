locals {
  packages_list = replace(yamlencode({provider:{packages:var.crossplane_providers}}), "\"", "")
}
resource "helm_release" "crossplane" {
    name = var.release_name
    chart = "crossplane"
    repository    = "https://charts.crossplane.io/stable"
    version       = var.chart_version
    namespace     = var.namespace
    recreate_pods = var.recreate_pods
    force_update  = var.force_update

    values = [
    templatefile("${path.module}/values/values.yaml", {
      crossplane_providers = local.packages_list
  })]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}
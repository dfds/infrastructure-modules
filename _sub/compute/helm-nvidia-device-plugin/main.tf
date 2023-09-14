resource "helm_release" "nvidia" {
  name       = "nvidia-device-plugin"
  chart      = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  version    = var.chart_version
  namespace  = var.namespace
  create_namespace = var.create_namespace

  values = [
    templatefile("${path.module}/values.yaml", {
      tolerations = var.tolerations,
      affinity = var.affinity
    })
  ]
}

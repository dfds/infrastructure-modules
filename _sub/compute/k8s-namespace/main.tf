resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.name
  }
}

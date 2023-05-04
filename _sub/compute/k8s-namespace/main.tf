resource "kubernetes_namespace" "namespace" {
  metadata {
    name   = var.name
    labels = var.namespace_labels
  }
}

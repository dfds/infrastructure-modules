resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      "iam.amazonaws.com/permitted" = var.iam_roles
    }
    name = var.name
  }
}

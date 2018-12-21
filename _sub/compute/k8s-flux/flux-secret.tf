resource "kubernetes_secret" "flux" {
  metadata {
    name = "flux-git-deploy"
    namespace = "${var.namespace}"
  }

  type = "Opaque"
  depends_on = ["kubernetes_namespace.flux_namespace"]
  provider = "kubernetes"
}

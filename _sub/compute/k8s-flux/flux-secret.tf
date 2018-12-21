resource "kubernetes_secret" "flux" {
  metadata {
    name = "flux-git-deploy"
    namespace = "${var.namespace}"
  }

  type = "Opaque"
  provider = "kubernetes"
}

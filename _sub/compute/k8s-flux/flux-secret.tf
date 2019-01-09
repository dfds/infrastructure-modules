resource "kubernetes_secret" "flux-git-deploy" {
  metadata {
    name      = "flux-git-deploy"
    namespace = "${var.namespace}"
  }

  data {
    identity = "${var.config_git_private_key}"
  }

  type       = "Opaque"
  depends_on = ["kubernetes_namespace.flux_namespace"]
  provider   = "kubernetes"
}

resource "kubernetes_secret" "flux-git-deploy" {
  count = var.deploy

  metadata {
    name      = "flux-git-deploy"
    namespace = var.namespace
  }

  data = {
    identity = var.git_key
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.flux_namespace]
  provider   = kubernetes
}


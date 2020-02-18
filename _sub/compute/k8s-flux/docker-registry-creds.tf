resource "kubernetes_secret" "docker-registry-creds" {
  count = var.deploy ? 1 : 0

  metadata {
    name      = "flux-docker-registry-creds"
    namespace = var.namespace
  }

  data = {
    ".dockerconfigjson" = "{\"auths\":{\"${var.registry_endpoint}\":{\"username\":\"${var.registry_username}\",\"password\":\"${var.registry_password}\",\"email\":\"${var.registry_email}\",\"auth\":\"${base64encode("${var.registry_username}:${var.registry_password}")}\"}}}"
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [kubernetes_namespace.flux_namespace]
  provider   = kubernetes
}


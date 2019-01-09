resource "kubernetes_secret" "docker-registry-creds" {
  metadata {
    name = "flux-docker-registry-creds"
    namespace = "${var.namespace}"
  }

  data {
    ".dockerconfigjson" = "{\"auths\":{\"${var.docker_registry_endpoint}\":{\"username\":\"${var.docker_registry_username}\",\"password\":\"${var.docker_registry_password}\",\"email\":\"${var.docker_registry_email}\",\"auth\":\"${base64encode("${var.docker_registry_username}:${var.docker_registry_password}")}\"}}}"
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = ["kubernetes_namespace.flux_namespace"]
  provider   = "kubernetes"  
}
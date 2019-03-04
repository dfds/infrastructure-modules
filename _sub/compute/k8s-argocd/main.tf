resource "kubernetes_namespace" "argocd_namespace" {
  count = "${var.deploy}"

  metadata {
    name = "${var.namespace}"
  }

  provider = "kubernetes"
}

resource "random_string" "password" {
  count            = "${var.deploy}"
  special          = true
  override_special = "{}[]!"
  length           = 24
}

resource "aws_ssm_parameter" "putSecureString" {
  count       = "${var.deploy}"
  name        = "/eks/${var.cluster_name}/argocd_admin"
  description = "Default admin password for ArgoCD"
  type        = "SecureString"
  value       = "${element(concat(random_string.password.*.result, list("")), 0)}"
  overwrite   = "true"
}

resource "helm_release" "argocd" {
  count        = "${var.deploy}"
  name         = "argocd"
  namespace    = "${var.namespace}"
  chart        = "${path.module}/argocd-chart"
  version      = "0.0.1"
  force_update = "true"

  values = [
    <<EOF
oidc:
  issuer: ${var.oidc_issuer}
  clientID: ${var.oidc_client_id}
  clientSecret: ${var.oidc_client_secret}
  
externalUrl: ${var.external_url}
hostUrl: ${var.host_url}
grpcHostUrl: ${var.grpc_host_url}
argoAppImage: ${var.argo_app_image}
EOF
    ,
    "${file("argocd_repos.yaml")}",
  ]

  depends_on = ["kubernetes_namespace.argocd_namespace"]
}

resource "null_resource" "set_password" {
  count = "${var.deploy}"

  provisioner "local-exec" {
    command = "${path.module}/set-admin-password.sh ${pathexpand("~/.kube/config_${var.cluster_name}")} ${var.host_url} ${var.grpc_host_url} ${element(concat(random_string.password.*.result, list("")), 0)}"
  }

  triggers {
    passwordChanged = "${sha512(element(concat(random_string.password.*.result, list("")), 0))}"
  }

  depends_on = ["helm_release.argocd"]
}

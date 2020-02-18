provider "aws" {
  version = "~> 2.43"
  region  = var.rsa_keypay_parameterstore_aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }

  alias = "parameterstore"
}

resource "kubernetes_namespace" "argocd_namespace" {
  count = var.deploy ? 1 : 0

  metadata {
    name = var.namespace
  }

  provider = kubernetes
}

resource "random_string" "password" {
  count            = var.deploy ? 1 : 0
  special          = true
  override_special = "{}[]!"
  length           = 24
}

resource "aws_ssm_parameter" "putSecureString" {
  count       = var.deploy ? 1 : 0
  name        = "/eks/${var.cluster_name}/argocd_admin"
  description = "Default admin password for ArgoCD"
  type        = "SecureString"
  value       = element(concat(random_string.password.*.result, [""]), 0)
  overwrite   = "true"
}

data "aws_ssm_parameter" "privateKey" {
  count       = var.deploy ? 1 : 0
  name            = var.rsa_keypair_key
  with_decryption = true
  provider        = aws.parameterstore
}

locals {
  id_rsa_filename = "${path.module}/id_rsa"
  project         = "selfservice"
  namespace       = "selfservice"
  appname         = "argocd-janitor"
  k8sserver       = "https://kubernetes.default.svc"
  kustomize_path  = "selfservice/overlays/production"
}

resource "local_file" "privateKey" {
  count             = var.deploy ? 1 : 0
  sensitive_content = data.aws_ssm_parameter.privateKey.*.value[0]
  filename          = local.id_rsa_filename
}

resource "helm_release" "argocd" {
  count     = var.deploy ? 1 : 0
  name      = "argocd"
  namespace = var.namespace
  chart     = "${path.module}/argocd-chart"
  version   = "0.0.1"

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
    file("argocd_repos.yaml"),
  ]

  depends_on = [kubernetes_namespace.argocd_namespace]
}

resource "null_resource" "set_password" {
  count = var.deploy ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/set-admin-password.sh ${pathexpand("~/.kube/config_${var.cluster_name}")} ${var.grpc_host_url} ${element(concat(random_string.password.*.result, [""]), 0)}"
  }

  triggers = {
    passwordChanged = sha512(element(concat(random_string.password.*.result, [""]), 0))
  }

  depends_on = [helm_release.argocd]
}

resource "null_resource" "create_project" {
  count = var.deploy ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/create-project.sh ${var.grpc_host_url} ${element(concat(random_string.password.*.result, [""]), 0)} selfservice"
  }

  depends_on = [
    helm_release.argocd,
    null_resource.set_password,
  ]
}

resource "null_resource" "create_repo" {
  count = var.deploy ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/create-repo.sh ${var.grpc_host_url} ${element(concat(random_string.password.*.result, [""]), 0)} ${var.default_repository} ${local.id_rsa_filename}"
  }

  depends_on = [
    helm_release.argocd,
    null_resource.set_password,
    local_file.privateKey,
  ]
}

resource "null_resource" "create_argocdjanitor" {
  count = var.deploy ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/create-application.sh ${var.grpc_host_url} ${element(concat(random_string.password.*.result, [""]), 0)} ${local.appname} ${local.namespace} ${local.project} ${local.k8sserver} ${var.default_repository} ${local.kustomize_path}"
  }

  depends_on = [
    helm_release.argocd,
    null_resource.create_repo,
  ]
}


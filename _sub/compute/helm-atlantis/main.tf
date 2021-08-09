## Atlantis ##

locals {
  full_github_repo_names = [
    for repo in var.github_repositories :
    "github.com/${repo}"
  ]
}

# --------------------------------------------------
# Generate random password and create a hash for it
# --------------------------------------------------

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "htpasswd_password" "hash" {
  password = random_password.password.result
  salt     = substr(sha512(random_password.password.result), 0, 8)
}

# --------------------------------------------------
# Save username and hashed password in a k8s secret
# --------------------------------------------------
resource "kubernetes_secret" "secret" {
  metadata {
    name      = local.auth_secret_name
    namespace = var.namespace
  }

  data = {
    auth = "${var.auth_username}:${htpasswd_password.hash.apr1}"
  }
}

# --------------------------------------------------
# Save password in AWS Parameter Store
# --------------------------------------------------
resource "aws_ssm_parameter" "param_atlantis_ui_auth" {
  name        = "/eks/${var.cluster_name}/${local.auth_secret_name}"
  description = "Password for accessing the Atlantis UI"
  type        = "SecureString"
  value       = random_password.password.result
  overwrite   = true
}

resource "random_password" "webhook_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "helm_release" "atlantis" {
  name             = "atlantis"
  chart            = "atlantis"
  repository       = "https://runatlantis.github.io/helm-charts"
  version          = var.chart_version != null ? var.chart_version : null
  namespace        = var.namespace
  create_namespace = false
  recreate_pods    = true
  force_update     = false

  set_sensitive {
    name  = "github.token"
    value = var.github_token
  }

  set_sensitive {
    name  = "github.secret"
    value = random_password.webhook_password.result
  }

  values = [
    templatefile("${path.module}/values/values.yaml", {
      atlantis_ingress    = var.atlantis_ingress,
      ingress_class       = local.ingress_class,
      ingress_auth_type   = local.ingress_auth_type,
      auth_secret_name    = local.auth_secret_name,
      atlantis_image      = var.atlantis_image,
      atlantis_image_tag  = var.atlantis_image_tag,
      github_username     = var.github_username,
      github_repos        = join(",", local.full_github_repo_names)
      storage_class       = var.storage_class
  })]

  depends_on = [kubernetes_secret.aws]
}

## Github ##

data "github_user" "github_user" {
  username = var.github_username
}

data "github_repository" "repo" {
  count     = length(var.github_repositories)
  full_name = var.github_repositories[count.index]
}

resource "github_repository_webhook" "hook" {
  count      = length(data.github_repository.repo)
  repository = data.github_repository.repo[count.index].name

  configuration {
    url          = "https://${var.auth_username}:${urlencode(random_password.password.result)}@${var.webhook_url}/events"
    content_type = var.webhook_content_type
    secret       = random_password.webhook_password.result
    insecure_ssl = false
  }

  events = var.webhook_events
}

## Kubernetes ##

resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws-credentials"
    namespace = var.namespace
  }

  data = {
    aws_access_key    = var.aws_access_key
    aws_secret        = var.aws_secret
    access_key_master = var.access_key_master
    secret_key_master = var.secret_key_master
  }
  depends_on = [kubernetes_namespace.namespace]
}

resource "kubernetes_secret" "az" {
  metadata {
    name      = "az-credentials"
    namespace = var.namespace
  }

  data = {
    arm_tenant_id       = var.arm_tenant_id
    arm_subscription_id = var.arm_subscription_id
    arm_client_id       = var.arm_client_id
    arm_client_secret   = var.arm_client_secret
  }
  depends_on = [kubernetes_namespace.namespace]
}

resource "kubernetes_secret" "gh" {
  metadata {
    name      = "gh-credentials"
    namespace = var.namespace
  }

  data = {
    github_token      = var.github_token
    github_token_flux = var.platform_fluxcd_github_token
  }
  depends_on = [kubernetes_namespace.namespace]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

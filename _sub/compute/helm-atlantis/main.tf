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

  depends_on = [helm_release.atlantis]
}

# --------------------------------------------------
# Save password in AWS Parameter Store
# --------------------------------------------------

resource "aws_ssm_parameter" "param_atlantis_ui_auth_username" {
  name        = "/eks/${var.cluster_name}/${local.auth_secret_name}-username"
  description = "Username for accessing the Atlantis UI"
  type        = "SecureString"
  value       = var.auth_username

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
}

resource "aws_ssm_parameter" "param_atlantis_ui_auth_password" {
  name        = "/eks/${var.cluster_name}/${local.auth_secret_name}-password"
  description = "Password for accessing the Atlantis UI"
  type        = "SecureString"
  value       = random_password.password.result

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
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
  version          = var.chart_version
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
      atlantis_ingress          = var.atlantis_ingress,
      ingress_class             = local.ingress_class,
      ingress_auth_type         = local.ingress_auth_type,
      auth_secret_name          = local.auth_secret_name,
      atlantis_image            = var.atlantis_image,
      atlantis_image_tag        = var.atlantis_image_tag,
      github_username           = var.github_username,
      github_repos              = join(",", local.full_github_repo_names)
      storage_class             = var.storage_class
      data_storage              = var.data_storage
      parallel_pool_size        = var.parallel_pool_size
      resources_requests_cpu    = var.resources_requests_cpu
      resources_requests_memory = var.resources_requests_memory
      resources_limits_cpu      = local.resources_limits_cpu
      resources_limits_memory   = local.resources_limits_memory
    }),
    yamlencode({
      environmentSecrets = [
        for key, value in var.environment_variables : {
          name : key
          secretKeyRef : {
            name : "env-secrets",
            key : key,
          }
        }
      ]
    })
  ]

  depends_on = [kubernetes_secret.env]
}

## Github ##

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

resource "kubernetes_namespace" "namespace" {
  metadata {
    name   = var.namespace
    labels = var.namespace_labels
  }
}

## Secrets ##

resource "kubernetes_secret" "env" {
  metadata {
    name      = "env-secrets"
    namespace = var.namespace
  }

  data       = var.environment_variables
  depends_on = [kubernetes_namespace.namespace]
}

locals {
  # pragma: allowlist nextline secret
  auth_secret_name        = "atlantis-basic-auth" #tfsec:ignore:general-secrets-sensitive-in-local
  ingress_class           = "traefik"
  ingress_auth_type       = "basic"
  resources_limits_memory = var.resources_limits_memory != null ? var.resources_limits_memory : var.resources_requests_memory
  resources_limits_cpu    = var.resources_limits_cpu != null ? var.resources_limits_cpu : var.resources_requests_cpu # null values are not legal in templatefile
}

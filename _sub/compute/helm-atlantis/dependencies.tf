locals {
  auth_secret_name  = "atlantis-basic-auth" #tfsec:ignore:general-secrets-sensitive-in-local
  ingress_class     = "traefik"
  ingress_auth_type = "basic"
}

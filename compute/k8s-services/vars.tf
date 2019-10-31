# --------------------------------------------------
# Terraform
# --------------------------------------------------

variable "terraform_state_s3_bucket" {
  type = "string"
}

variable "terraform_state_region" {
  type = "string"
}

# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_workload_account_id" {}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "workload_dns_zone_name" {}

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = "string"
}

# --------------------------------------------------
# Traefik
# --------------------------------------------------

variable "traefik_deploy" {
  default = false
}

variable "traefik_version" {
  type = "string"
  default = "1.7.19"
}

variable "traefik_deploy_name" {}

variable "traefik_alb_anon_deploy" {
  default = false
}

variable "traefik_alb_auth_deploy" {
  default = false
}

variable "traefik_alb_auth_core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certficate should also be valid for. E.g. 'prettyurl.company.tld'"
  type    = "list"
  default = []
}

variable "traefik_nlb_deploy" {
  default = false
}

variable "traefik_nlb_cidr_blocks" {
  type = "list"
  default = []
}

variable "blaster_configmap_deploy" {
  default = false
}

# --------------------------------------------------
# KIAM
# --------------------------------------------------

variable "kiam_deploy" {
  default = false
}

# --------------------------------------------------
# Blaster
# --------------------------------------------------

variable "blaster_deploy" {
  default = false
}

# --------------------------------------------------
# Service Broker
# --------------------------------------------------

variable "servicebroker_deploy" {
  default = false
}

# --------------------------------------------------
# ArgoCD
# --------------------------------------------------

variable "argocd_deploy" {
  default = false
}

variable "argocd_default_repository" {
  type = "string"
}

# --------------------------------------------------
# Harbor
# --------------------------------------------------

variable "harbor_deploy" {
  default = false
}

variable "harbor_k8s_namespace" {
  type = "string"
}

variable "harbor_db_instance_size" {
  type = "string"
}

variable "harbor_postgresdb_engine_version" {
  type = "string"
}

variable "harbor_db_storage_size" {
  type = "string"
}

variable "harbor_db_server_username" {
  type = "string"
}

variable "harbor_postgresdb_default_db_name" {
  type = "string"
  default = "postgres"
}

# --------------------------------------------------
# Flux
# --------------------------------------------------

variable "flux_deploy" {
  default = false
}

variable "flux_k8s_namespace" {
  description = "Namespace where flux daemon should run."
}

variable "flux_git_url" {
  description = "Git url for the repo that holds service kubernetes manifests."
}

variable "flux_git_branch" {
  description = "Git branch to use."
}

variable "flux_git_label" {
  description = "Git branch to use."
}

variable "flux_git_key_base64" {
  description = "Private key string encoded as base64 to access the git repo."
}

variable "flux_registry_endpoint" {
  description = "The FQDN of docker registry server. A valid enpoint could be yourdomain.com"
}

variable "flux_registry_username" {
  description = "Username for the user that enables Flux to read the docker registry information."
}

variable "flux_registry_password" {
  description = "Password for the user that enables Flux to read the docker registry information."
}

variable "flux_registry_email" {
  description = "Email address for the user that enables Flux to read the docker registry information."
}

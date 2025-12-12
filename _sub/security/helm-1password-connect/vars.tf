variable "cluster_name" {
  type = string
}

variable "github_owner" {
  type        = string
  description = "Name of the Github owner (previously: organization)"
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
}

variable "gitops_apps_repo_url" {
  type        = string
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  description = "The default branch or tag for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}


# --------------------------------------------------
# IRSA variables
# --------------------------------------------------

variable "oidc_issuer" {
  type        = string
  description = "The OIDC isssue for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  description = "The workload account ID."
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}

# --------------------------------------------------
# SSM variables
# --------------------------------------------------

variable "credentials_json" {
  type        = string
  sensitive   = true
  description = "The 1Password Connect credentials JSON"
}

variable "token_for_atlantis" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The 1Password Connect tokens to be stored in SSM if Atlantis is enabled"
}

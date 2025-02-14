variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "1password-connect"
}

variable "chart_version" {
  type        = string
  description = "The helm chart version"
  default     = ""
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "1password-connect"
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
  default     = null
}

variable "helm_chart_version" {
  type        = string
  description = "The version of the chart that should be used"
  default     = ""
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
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

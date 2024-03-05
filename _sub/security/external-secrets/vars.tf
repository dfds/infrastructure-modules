variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "external-secrets"
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "external-secrets"
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
  description = "The version of the Traefik v2 Helm Chart that should be used"
  default     = null
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

variable "oidc_issuer" {
  type        = string
  default     = null
  description = "The OIDC isssue for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  default     = null
  description = "The workload account ID."
}

variable "iam_role_name" {
  type        = string
  description = "The name of the IAM role to assume"
  default     = "ssm-secrets-for-kubernetes"
}

variable "service_account" {
  type        = string
  default     = "ssm-secrets"
  description = "The service account to be used by an SecretStore"
}

variable "allowed_namespaces" {
  type        = list(string)
  default     = []
  description = "The namespaces that can use IRSA to access external secrets"
}

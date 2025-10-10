variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "external-dns"
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "external-dns"
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
  default     = ""
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

variable "cluster_region" {
  type        = string
  description = "The AWS region the EKS cluster is deployed in"
}

variable "role_arn" {
  type        = string
  description = "The ARN of the role to be used by external-dns"
}

variable "assume_role_arn" {
  type        = string
  description = "The ARN of the role to be assumed by external-dns to manage DNS records in other AWS accounts"
}

variable "deletion_policy_override" {
  type        = string
  description = "Explictly set the deletion policy for the external-dns helm release. Options are: 'sync' and 'upsert-only'. if not set, the default behavior of external-dns is set by the helm chart"
  default     = ""
}

variable "domain_filters" {
  type        = list(string)
  description = "List of domain filters for external-dns to manage. Example: ['dfds.cloud', 'example.com']"
  default     = []
}

variable "is_debug_mode" {
  type        = bool
  description = "If it is set to true then logLevel will be set to debug."
  default     = false
}

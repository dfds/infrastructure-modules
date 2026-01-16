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
  default     = null
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  default     = "main"
  description = "The default branch or tag for your GitOps manifests"
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
variable "domain_name" {
  type        = string
  description = "The domain name to be used by cert-manager"
}

variable "acme_email" {
  type        = string
  description = "The email address to be used for ACME registration with cert-manager"
}

variable "iam_role_arn" {
  type = string
  description = "The IAM Role ARN to be used by cert-manager for DNS01 challenge"
}
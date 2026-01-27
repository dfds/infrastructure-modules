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

variable "deletion_policy_override" {
  type        = string
  description = "Explictly set the deletion policy for the external-dns helm release. Options are: 'sync' and 'upsert-only'. if not set, the default behavior of external-dns is set by the helm chart"
  default     = ""
}

variable "is_debug_mode" {
  type        = bool
  description = "If it is set to true then logLevel will be set to debug."
  default     = false
}

variable "target_anon" {
  type        = string
  description = "The target DNS name for the public records"
}

variable "target_auth" {
  type        = string
  description = "The target DNS name for the authenticated records"
}

variable "dns_records_anon" {
  type        = list(string)
  description = "The DNS records to create for the public services"
}
variable "dns_records_auth" {
  type        = list(string)
  description = "The DNS records to create for the login-protected services"
}

variable "domain" {
  type        = string
  description = "The domain for the DNS records"
}

variable "zone_id_core" {
  type = string
  description = "The Route53 Hosted Zone ID for the core DNS zone"
}

variable "zone_id_workload" {
  type = string
  description = "The Route53 Hosted Zone ID for the workload DNS zone"
}
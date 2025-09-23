variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "traefik"
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "external-dns"
}

# variable "replicas" {
#   description = "zzzzzzzzzz"
#   type        = number
# }

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

variable "cluster_region" {
  type = string
  description = "The AWS region the EKS cluster is deployed in"
}

variable "role_arn" {
  type = string
  description = "The ARN of the role to be used by external-dns"
}

variable "assume_role_arn" {
  type = string
  description = "The ARN of the role to be assumed by external-dns to manage DNS records in other AWS accounts"
}

variable "deletion_policy" {
  type        = string
  description = "The deletion policy for the external-dns helm release. Options are: 'sync' and 'upsert-only'"
}

variable "domain_filters" {
  type        = list(string)
  description = "List of domain filters for external-dns to manage. Example: ['dfds.cloud', 'example.com']"
  default     = []
}

variable "apply_text_prefix" {
  type        = bool
  description = "Whether to apply a text prefix to the txt records created by external-dns. Useful to avoid conflicts if multiple external-dns instances are running in the same account"
  default     = false
}

variable "txt_owner_id" {
  type        = string
  description = "The owner id to use for the txt records created by external-dns. Defaults to the cluster name. Useful to avoid conflicts if multiple external-dns instances are running in the same account"
  default     = ""
}
variable "sources" {
  type        = list(string)
  description = "The sources to watch for DNS records."
  default     = ["ingress", "service"]
}

variable "allowed_record_types" {
  type        = list(string)
  description = "List of allowed DNS records to be managed by External DNS."
  default     = ["CNAME"]
}
# --------------------------------------------------
# Flux CD bootstrap variables
# --------------------------------------------------

variable "github_owner" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "release_tag" {
  type = string
  validation {
    condition     = (tonumber(split(".", trim(var.release_tag, "v"))[0]) == 2 && tonumber(split(".", trim(var.release_tag, "v"))[1]) >= 6) || tonumber(split(".", trim(var.release_tag, "v"))[0]) >= 3
    error_message = "Fluxcd version must be v2.6.0 or higher."
  }
}

# --------------------------------------------------
# Custom variables
# --------------------------------------------------

variable "cluster_name" {
  type = string
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "gitops_apps_repo_tag" {
  type        = string
  description = "Use a release tag instead of branch for your GitOps manifests. Tags beat branches if both are set."
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "endpoint" {
  type = string
}

variable "token" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "enable_monitoring" {
  type        = bool
  default     = false
  description = "Enable monitoring for Flux"
}

variable "tenants" {
  type = list(object({
    namespace = string
    repositories = list(object({
      url    = string
      branch = string
      path   = optional(string, null),
    }))
  }))
  description = "List of tenants' namespaces and repository URLs"
  default     = []
}

variable "source_controller_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the IAM role for the source controller. Used for IAM roles for service accounts (IRSA). Optional."
}

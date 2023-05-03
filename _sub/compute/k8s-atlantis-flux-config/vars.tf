## Atlantis ##

variable "namespace" {
  type        = string
  description = "The namespace where Atlatis is installed"
  default     = "atlantis"
}

variable "cluster_name" {
  type = string
}
variable "ingressroute_hostname" {
  type        = string
  description = "The hostname to use in an ingressroute rule match"
}

variable "repo_owner" {
  type        = string
  description = "Github username or organization that owns the repo to store the Atlantis Flux manifests in"
  default     = null
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the Atlantis Flux manifests in"
  default     = null
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the Atlantis Flux repo (optional)"
  default     = "main"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

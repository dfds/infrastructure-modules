variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name for writing Flux manifests to."
}

variable "repo_branch" {
  type        = string
  default     = "main"
  description = "The git branch."
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "cluster_name" {
  type = string
}

variable "repo_name" {
  type        = string
  description = ""
}

variable "repo_branch" {
  type        = string
  default     = "main"
  description = ""
}

variable "repo_path" {
  type        = string
  description = ""
}

variable "github_owner" {
  type        = string
  description = ""
}

variable "kubeconfig_path" {
  type    = string
  default = null
}

variable "release_tag" {
  type    = string
  default = "latest"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

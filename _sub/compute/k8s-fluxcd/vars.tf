variable "repo_name" {
  type        = string
  description = ""
}

variable "repo_visibility" {
  type    = string
  default = "private"
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

variable "github_token" {
  type        = string
  description = ""
}

variable "kubeconfig_path" {
  type    = string
  default = null
}

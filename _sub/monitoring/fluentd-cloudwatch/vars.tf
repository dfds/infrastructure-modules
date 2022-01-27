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

variable "github_owner" {
  type        = string
  description = ""
}

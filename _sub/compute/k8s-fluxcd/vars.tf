variable "namespace" {
  type        = string
  description = ""
}

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


# Provider crap - really want to inherit provider config from main module!

variable "kubectl_provider_host" {
  type        = string
  description = ""
}

variable "kubectl_provider_cluster_ca_certificate" {
  type        = string
  description = ""
}

variable "kubectl_provider_token" {
  type        = string
  description = ""
}

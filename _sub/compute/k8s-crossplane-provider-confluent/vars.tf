variable "email" {
  type = string
  description = "Confluent global admin account email"
}

variable "password" {
  type = string
  description = "Confluent global admin account password"
  sensitive = true
}

variable "namespace" {
  type = string
  description = "Namespace to deploy in"
}

variable "confluent_environments" {
  type = map
  description = "Supported Confluent environments"
  default = {}
}

variable "confluent_clusters" {
  type = map
  description = "Supported Confluent Clusters for each environment"
  default = {}
}

variable "repo_owner" {
  type        = string
  description = "Github username or organization that owns the repo to store the Flux manifests in"
  default     = null
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the Flux manifests in"
  default     = null
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the Flux repo (optional)"
  default     = "main"
}

variable "cluster_name" {
  type = string
}
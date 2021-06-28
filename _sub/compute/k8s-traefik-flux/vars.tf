variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "traefik"
}

variable "http_nodeport" {
  description = "Nodeport used by ALB's to connect to the Traefik instance"
  type        = number
}

variable "admin_nodeport" {
  description = "Nodeport used by ALB's to connect to the Traefik instance admin page"
  type        = number
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
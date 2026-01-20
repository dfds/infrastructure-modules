variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier for blue/green deployments"
  validation {
    condition     = contains(["traefik-blue-variant", "traefik-green-variant"], var.deploy_name)
    error_message = "The deploy_name must be either 'traefik-blue-variant' or 'traefik-green-variant'."
  }
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
}

variable "dns_zone_name" {
  type        = string
  description = "The workload DNS zone name."
}

variable "gitops_apps_repo_url" {
  type        = string
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  description = "The default branch or tag for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

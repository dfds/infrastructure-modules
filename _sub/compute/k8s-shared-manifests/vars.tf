variable "cluster_name" {
  type = string
}

variable "overlay_folder" {
  type = string
}

variable "repo_owner" {
  type        = string
  description = "Name of the repo owner (previously: organization)"
  sensitive   = true
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
  default     = "main"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "shared_manifests_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "shared_manifests_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "shared_manifests_repo_name" {
  type        = string
  description = "Name of the Github repo to read the shared manifests from"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

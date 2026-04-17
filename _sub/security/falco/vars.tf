variable "cluster_name" {
  type = string
}

variable "repo_owner" {
  type        = string
  description = "Name of the repo owner (previously: organization)"
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
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

variable "slack_alert_webhook_url" {
  type        = string
  description = "Value for slack webhook url to which to send alerts."
}

variable "stream_webhook_url" {
  type        = string
  description = "Value for webhook url to which to send falco events stream."
}

variable "custom_rules" {
  type        = string
  description = "Custom rules to be added to the falco config"
}

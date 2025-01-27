variable "cluster_name" {
  type = string
}

variable "chart_version" {
  type        = string
  description = "The Helm Chart version that should be used"
  default     = ""
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "falco"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy the application into"
  default     = "falco"
}

variable "github_token" {
  type        = string
  description = "Github token to authenticate with"
  sensitive   = true
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
  default     = "main"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "slack_alert_webhook_url" {
  type        = string
  default     = ""
  description = "Value for slack webhook url to which to send alerts. If not provided, slack alerts will not be sent"
}

variable "slack_alert_channel_name" {
  type        = string
  default     = ""
  description = "Channel name for slack alerts. Example: #falco-alerts"
}

variable "slack_alert_minimum_priority" {
  type        = string
  default     = "critical"
  description = "Minimum priority level for slack alerts. Valid options are: "
}

variable "stream_enabled" {
  type        = bool
  default     = false
  description = "Enable Falco stream output to a specified webhook"
}

variable "stream_webhook_url" {
  type        = string
  default     = ""
  description = "Value for webhook url to which to send falco events stream. stream_enabled must be set to true. If not provided, slack stream will not be sent"
}

variable "stream_channel_name" {
  type        = string
  default     = ""
  description = "Channel name for falco stream. Example: #falco-stream"
}

variable "custom_rules" {
  type        = string
  default     = ""
  description = "Custom rules to be added to the falco config"
}

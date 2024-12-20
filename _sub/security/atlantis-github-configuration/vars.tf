variable "dashboard_password" {
  description = "The password for the Atlantis dashboard"
  type        = string
}

variable "enable_github_secrets" {
  type        = bool
  default     = true
  description = "Enable Github secrets for Atlantis"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
  default     = []
}

variable "ingress_hostname" {
  type        = string
  description = "The hostname for the Atlantis ingress"
}

variable "webhook_events" {
  description = "A list of events that should trigger the webhook"
  default     = []
  type        = list(string)
}

variable "webhook_secret" {
  description = "The password for the webhook"
  type        = string
}

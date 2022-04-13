## Atlantis ##

variable "namespace" {
  type        = string
  description = ""
  default     = "atlantis"
}

variable "chart_version" {
  type        = string
  description = ""
  default     = null
}

variable "atlantis_ingress" {
  type        = string
  description = ""
}

variable "atlantis_image" {
  type        = string
  description = ""
  default     = "dfdsdk/atlantis-prime-pipeline"
}

variable "atlantis_image_tag" {
  type        = string
  description = "Tag of the Atlantis image to use"
  default     = "latest"
}

variable "github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
  default     = []
}

variable "arm_tenant_id" {
  type        = string
  description = ""
}

variable "arm_subscription_id" {
  type        = string
  description = ""
}

variable "arm_client_id" {
  type        = string
  description = ""
}

variable "arm_client_secret" {
  type        = string
  description = ""
}

variable "storage_class" {
  type        = string
  description = "Storage class to use for the persistent volume"
}

## Github ##
variable "github_token" {
  description = "Github token that the provider uses to perform Github operations. Leaving unset will fall back to GITHUB_TOKEN environment variable"
}

variable "platform_fluxcd_github_token" {
  description = "Github token that the provider uses to perform Github operations for Flux."
}


variable "github_username" {
  description = "Github username of the account that will post Atlantis comments on PR's"
}

variable "webhook_url" {
  description = "URL for the deployed Atlantis endpoint listener"
}

variable "webhook_content_type" {
  default = "application/json"
}

variable "webhook_insecure_ssl" {
  default = false
}

variable "webhook_events" {
  description = "A list of events that should trigger the webhook"
  default     = []
  type        = list(string)
}

## Kubernetes ##

variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret" {
  description = "AWS Secret"
}

variable "access_key_master" {
  type        = string
  description = "Access Key for Core account"
}

variable "secret_key_master" {
  type        = string
  description = "Secret for Core account"
}

variable "auth_username" {
  type        = string
  description = "Username used for basic authentication."
  default     = "cloudengineer"
}

variable "cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster"
}

variable "confluent_email" {
  type = string
  description = "Email used for Crossplane provider Confluent"
}

variable "confluent_password" {
  type = string
  description = "Password used for Crossplane provider Confluent"
  sensitive = true
}
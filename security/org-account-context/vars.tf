#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
}

variable "core_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Core account"
}

variable "shared_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Shared account (e.g. Oxygen)"
}

variable "shared_role_path" {
  type        = string
  description = "The path in which to put the IAM role for access to resources in shared account"
  default     = "/"
}

variable "access_key_master" {
  type = string
}

variable "secret_key_master" {
  type = string
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "prime_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "context_id" {
  type        = string
  description = "The ID of the context, for which to create and AWS account"
}

variable "correlation_id" {
  type = string
}

variable "capability_root_id" {
  type = string
}

variable "capability_name" {
  type = string
}

variable "capability_id" {
  type = string
}

variable "context_name" {
  type = string
}

variable "kafka_broker" {
  type = string
}

variable "kafka_username" {
  type = string
}

variable "kafka_password" {
  type = string
}

variable "publish_message" {
  type    = bool
  default = true
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent AWS Organization OU."
  default     = ""
}

variable "oidc_provider_url" {
  type        = string
  description = "The IAM OpenID Connect Provider url from the EKS production account"
  default     = ""
}

variable "oidc_provider_tag" {
  type        = string
  description = "Used for tagging the IAM OpenID Connect Provider for the capability account"
  default     = ""
}

variable "harden" {
  type    = bool
  default = false
}

variable "hardened_monitoring_email" {
  type    = string
  default = null
}

variable "aws_region_sso" {
  type    = string
  default = "eu-west-1"
}

variable "sso_support_permission_set_name" {
  type    = string
  default = null
}

variable "sso_support_group_name" {
  type    = string
  default = null
}

variable "aws_region_2" {
  type        = string
  description = "Terraform has limitations that prevent us from dynamically creating AWS providers for each region, so instead of providing a list of regions we will specifiy an incremented set of variables to deploy resources across multiple regions."
  default     = "eu-west-1"
}

variable "datadog_enabled" {
  type    = bool
  default = false
}

variable "datadog_api_key" {
  type    = string
  default = null
}

variable "datadog_app_key" {
  type    = string
  default = null
}

variable "datadog_api_url" {
  type    = string
  default = "https://api.datadoghq.eu"
}

variable "datadog_aws_account_id" {
  type    = string
  default = null
}

variable "datadog_filter_tags" {
    type = list(string)
    default = null
}

variable "datadog_host_tags" {
    type = list(string)
    default = []
}

variable "datadog_account_specific_namespace_rules" {
    type = map(bool)
    default = null
}

variable "datadog_metrics_collection_enabled" {
    type = bool
    default = true
}

variable "datadog_resource_collection_enabled" {
    type = bool
    default = false
}
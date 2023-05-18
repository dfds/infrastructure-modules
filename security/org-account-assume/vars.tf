#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}
variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
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

variable "prime_role_max_session_duration" {
  type    = string
  default = 7200 # 2 hours
}

variable "email" {
  type = string
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent AWS Organization OU. Defaults to the root."
  default     = "r-65k1"
}

variable "aws_region_sso" {
  type    = string
  default = "eu-west-1"
}

variable "sso_admin_permission_set_name" {
  type = string
}

variable "sso_admin_group_name" {
  type = string
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
#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "create_cloudtrail_s3_bucket" {
  type    = bool
  default = false
}

variable "cloudtrail_central_s3_bucket" {
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
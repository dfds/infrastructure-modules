variable "deploy" {
  type    = bool
  default = false
}

variable "aws_account_id" {
  type    = string
  default = null
}

variable "datadog_aws_account_id" {
  type    = string
  default = null
}

variable "datadog_integration_role_name" {
  type    = string
  default = "DatadogIntegrationRole"
}

variable "filter_tags" {
    type = list(string)
    default = null
}

variable "host_tags" {
    type = list(string)
    default = null
}

variable "account_specific_namespace_rules" {
    type = map(bool)
    default = null
}

variable "metrics_collection_enabled" {
    type = bool
    default = true
}

variable "resource_collection_enabled" {
    type = bool
    default = false
}
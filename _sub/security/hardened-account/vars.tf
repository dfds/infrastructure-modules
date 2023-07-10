variable "harden" {
  type    = bool
  default = false
}

variable "account_id" {
  type = string
}

variable "account_name" {
  type = string
}

variable "security_bot_lambda_version" {
  type = string
}

variable "security_bot_lambda_s3_bucket" {
  type        = string
  description = "The S3 bucket where the Security Bot Lambda package is stored."
}

variable "monitoring_email" {
  type    = string
  default = null
}

variable "monitoring_slack_channel" {
  type    = string
  default = null
}

variable "monitoring_slack_token" {
  type      = string
  sensitive = true
  default   = null
}

variable "security_contact_name" {
  type = string
}

variable "security_contact_title" {
  type = string
}

variable "security_contact_email" {
  type = string
}

variable "security_contact_phone_number" {
  type = string
}

variable "sso_support_permission_set_name" {
  type    = string
  default = null
}

variable "sso_support_group_name" {
  type    = string
  default = null
}

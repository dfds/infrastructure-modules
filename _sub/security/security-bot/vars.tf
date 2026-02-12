variable "deploy" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "account_name" {
  type = string
}

variable "lambda_version" {
  type = string
}

variable "lambda_s3_bucket" {
  type        = string
  description = "The S3 bucket where the Lambda package is stored."
}

variable "slack_token" {
  type      = string
  sensitive = true
}

variable "slack_channel" {
  type = string
}

variable "sns_topic_arn_compliance_changes" {
  type        = string
  description = "The SNS topic where changes to AWS Config resource compliance are published."
}

variable "sns_topic_arn_guard_duty_findings" {
  type        = string
  description = "Fisrt SNS topics where GuardDuty findings are published."
}

variable "sns_topic_arn_guard_duty_findings_2" {
  type        = string
  description = "Second SNS topics where GuardDuty findings are published."
}

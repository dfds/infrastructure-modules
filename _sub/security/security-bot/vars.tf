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

variable "cloudwatch_logs_group_name" {
  type        = string
  description = "The name of the CloudWatch log group containing the CloudTrail events triggering the alarms."
}

variable "cloudwatch_logs_group_arn" {
  type        = string
  description = "The arn of the CloudWatch log group containing the CloudTrail events triggering the alarms."
}

variable "sns_topic_arn_cis_controls" {
  type        = string
  description = "The SNS topic where alerts are published related to the CIS controls."
}

variable "sns_topic_arn_compliance_changes" {
  type        = string
  description = "The SNS topic where changes to AWS Config resource compliance are published."
}

variable "sns_topic_arn_guard_duty_findings" {
  type        =  list(string)
  description = "The SNS topics where GuardDuty findings are published."
}

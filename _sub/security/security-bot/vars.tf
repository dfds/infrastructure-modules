variable "deploy" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "slack_token" {
  type      = string
  sensitive = true
}

variable "slack_channel" {
  type = string
}

variable "capability_root_id" {
  type        = string
  description = "The capability root ID for the AWS account that the bot will be monitoring."
}

variable "cloudwatch_logs_group_arn" {
  type        = string
  description = "The CloudWatch log group containing the CloudTrail events triggering the alarms."
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
  type        = string
  description = "The SNS topic where GuardDuty findings are published."
}

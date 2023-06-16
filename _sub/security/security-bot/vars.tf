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

variable "alarm_sns_topic_arn" {
  type        = string
  description = "The SNS topic where alerts are published."
}

variable "cloudwatch_logs_group_arn" {
  type        = string
  description = "The CloudWatch log group containing the CloudTrail events triggering the alarms."
}

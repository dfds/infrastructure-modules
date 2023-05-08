variable "deploy" {
  description = "Deploy CloudWatch alarm."
  type        = bool
  default     = true
}

variable "metric_filter_name" {
  description = "The name of the metric filter that will be added to the log group."
  type        = string
}

variable "metric_filter_pattern" {
  description = "The pattern the metric filter will apply the to the logged events."
  type        = string
}

variable "logs_group_name" {
  description = "The name of the CloudWatch log group to which the metric filter will be attached."
  type        = string
}

variable "metric_name" {
  description = "The name of the metric that is produced by the metric filter."
  type        = string
}

variable "metric_namespace" {
  description = "The namespace of the metric that is produced by the metric filter."
  type        = string
  default     = "LogMetrics"
}

variable "metric_value" {
  description = "The value of the metric that is produced by the metric filter."
  type        = string
  default     = "1"
}

variable "alarm_name" {
  description = "The name of the CloudWatch alarm."
  type        = string
}

variable "alarm_description" {
  description = "The description of the CloudWatch alarm."
  type        = string
}

variable "alarm_sns_topic_arn" {
  description = "The ARN of the SNS topic to which events from the CloudWatch alarm should be published."
  type        = string
}

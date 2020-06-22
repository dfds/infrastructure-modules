variable "deploy" {
  type    = bool
  default = true
}

variable "sns_name" {
  type = string
  default = "cloudwatch-alarms"
}

variable "slack_webhook_url" {
  type = string
}

variable "function_name" {
	type = string
}

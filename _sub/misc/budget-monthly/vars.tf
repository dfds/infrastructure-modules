variable "sns_topic_arn" {
  type = string
}

variable "budget_limit" {
  type = number
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

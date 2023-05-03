variable "sns_topic_arn" {
  type = string
}

variable "check_period" {
  type    = string
  default = "300"
}

variable "deploy" {
  type    = bool
  default = true
}

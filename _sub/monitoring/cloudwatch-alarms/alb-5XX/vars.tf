variable "sns_topic_arn" {
  type = string
}

variable "check_period" {
  type    = string
  default = "60"
}

variable "check_threshold" {
  type    = string
  default = "20"
}

variable "alb_arn_suffix" {
  type = string
}

variable "deploy" {
  type    = bool
  default = true
}

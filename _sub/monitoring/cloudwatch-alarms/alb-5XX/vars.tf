variable "sns_topic_arn" {
  type = string
}

variable "check_period" {
  type = string
  default = "60"
}

variable "check_threshold" {
  type = string
  default = "5"
}

variable "alb_arn_suffixes" {
  type = list(string)
}

variable "deploy" {
  type = bool
  default = true
}
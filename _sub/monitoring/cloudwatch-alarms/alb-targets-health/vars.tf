variable "sns_topic_arn" {
  type = string
}

variable "alb_target_exists_check_period" {
  type    = string
  default = "60"
}

variable "alb_target_exists_check_threshold" {
  type    = string
  default = "1"
}

variable "alb_target_healthy_check_period" {
  type    = string
  default = "60"
}

variable "alb_target_healthy_check_threshold" {
  type    = string
  default = "1"
}

variable "deploy" {
  type    = bool
  default = true
}

variable "alb_target_group_arn_suffixes" {
  type = list(string)
}

variable "alb_arn_suffixes" {
  type = list(string)
}
variable "deploy" {
  type    = bool
  default = true
}

variable "function_name" {
  type = string
  #default = "cloudwatch_alb_500_to_slack"
}

variable "slack_channel" {
  type = string
}

variable "slack_hook" {
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

variable "check_metric" {
    type = string
    default = "HTTPCode_ELB_5XX_Count" #put "RequestCount" for rapid testing
}

variable "check_namespace" {
  type = string
  default = "AWS/ApplicationELB"
}

variable "sns_name" {
  type = string
}

variable "albs" {
  type = list(string)
   #default = ["app/coke-traefik-alb/3ec7dd954526d14e", "net/coke-istio-nlb/69a21b60d0f8c176"]
}





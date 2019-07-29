variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "cf_main_hosted_zone_deploy" {
  default = ""
}

variable "cf_main_dns_zone" {
  default = ""
}

variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "cf_domain_cert_deploy" {
  default = false
}

variable "dns_zone_id" {
  default = ""
}

variable "cf_main_dns_zone" {
  
}

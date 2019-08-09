variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "cf_route53_records_deploy" {
  default = false
}

variable "dns_zone_id" {
  default = ""
}

variable "cf_distribution_domain_name" {
  
}

variable "cf_distribution_hosted_zone_id" {
  default = ""
}

variable "cf_distribution_domain_name" {
  default = ""
}

variable "cf_dns_zone" {
  
}


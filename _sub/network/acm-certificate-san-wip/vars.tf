variable "deploy" {
  default = true
}

variable "dns_zone_name" {}

variable "domain_name" {}

variable "core_alt_names" {
  type = "list"
  default = []
}


#

variable "aws_region" {}

variable "aws_assume_role_arn" {}
variable "aws_region" {
  type = "string"
}

variable "aws_workload_account_id" {
  type = "string"
  description = "The AWS account ID of the Workload account to create the DNS zone in"
}

variable "prime_role_name" {
  type = "string"
}

variable "dns_zone_name" {
  type = "string"
}
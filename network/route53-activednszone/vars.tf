#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
#By default route53 generates 4 nameservers for a zone which is why there is 4 (zeroindexed) zone-ns variables
variable "aws_region" {
  type = "string"
}

variable "dns_zone_name" {
  type = "string"
}

variable "dns_zone_id" {
  type = "string"
}

variable "dns_zone_ns" {
  type = "list"
}
#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
#By default route53 generates 4 nameservers for a zone which is why there is 4 (zeroindexed) zone-ns variables
variable "aws_region" {
  type = "string"
}

variable "aws_dns_zone" {
  type = "string"
}

variable "aws_dns_id" {
  type = "string"
}

variable "route53-zone-ns0" {
  type = "string"
}

variable "route53-zone-ns1" {
  type = "string"
}

variable "route53-zone-ns2" {
  type = "string"
}

variable "route53-zone-ns3" {
  type = "string"
}
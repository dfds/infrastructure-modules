#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
}

variable "aws_dns_zone" {
  type = "string"
}
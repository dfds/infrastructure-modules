#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
  default = "eu-central-1"
}

variable "root_dns" {
  type = "string"
}

variable "aws_dns_zone" {
  type = "string"
}

variable "target_account_id" {
  type = "string"
}

variable "role_to_assume" {
  type = "string"
  default = "OrgRole"
  
}


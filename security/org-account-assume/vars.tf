#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
}

variable "assume_role_arn" {
  type = "string"
  description = "The ARN of the role to assume, for creating the account"
}

variable "aws_account_name" {
  type = "string"
}

variable "aws_org_rolename" {
  type = "string"
}

variable "email_domain" {
  type = "string"
}
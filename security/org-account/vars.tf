#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
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

variable "cloudtrail_trail_name" {
  type = "string"
}

variable "cloudtrail_s3_bucket" {
  type = "string"
}

variable "tax_settings_document" {
  type = "string"
  default = "./taxsettings.json"
}

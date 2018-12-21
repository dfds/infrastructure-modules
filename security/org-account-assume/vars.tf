#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
}

variable "assume_role_arn" {
  type = "string"
  description = "The ARN of the role to assume, for creating the account"
}

variable "access_key_master" {
  type = "string"
}

variable "secret_key_master" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "org_role_name" {
  type = "string"
}

variable "prime_role_name" {
  type = "string"
}
variable "email" {
  type = "string"
}

variable "tax_settings_document" {
  type = "string"
  default = "./taxsettings.json"
}

variable "cloudtrail_trail_name" {
  type = "string"
}

variable "cloudtrail_s3_bucket" {
  type = "string"
}

variable "cloudtrail_local_s3_bucket" {
  type = "string"
  default = ""
}
#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

# variable "aws_assume_role_arn" {
#   type = "string"
#   description = "The ARN of the role to assume, for creating the account"
# }

variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
}

variable "access_key_master" {
  type = string
}

variable "secret_key_master" {
  type = string
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "prime_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "tax_settings_document" {
  type    = string
  default = "./taxsettings.json"
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "adfs_fqdn" {
  type        = string
  description = "The fully-qualified domain name of the ADFS server, e.g. adfs.company.tld"
}


# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}

variable "terraform_state_aws_region" {
  type    = string
  default = ""
}
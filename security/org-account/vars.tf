#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "create_cloudtrail_s3_bucket" {
  default = false
}

variable "cloudtrail_central_s3_bucket" {
  type = string
}

# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "aws_account_name" {
  type    = string
  default = ""
}

variable "terraform_state_region" {
  type    = string
  default = ""
}

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}

variable "terraform_state_aws_region" {
  type    = string
  default = ""
}

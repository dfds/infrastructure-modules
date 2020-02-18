# --------------------------------------------------
# AWS
# --------------------------------------------------
variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "keypairname" {
  description = "Name the Keypair will be saved as in AWS Parameter Store"
}

variable "deploy" {
  type = bool
  default = true
}

# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "aws_workload_account_id" {
  type    = string
  default = ""
}

variable "terraform_state_region" {
  type    = string
  default = ""
}

variable "workload_dns_zone_name" {
  type    = string
  default = ""
}

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}

variable "prime_role_name" {
  type    = string
  default = ""
}
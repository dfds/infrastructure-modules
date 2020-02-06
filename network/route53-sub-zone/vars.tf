#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "aws_workload_account_id" {
  type        = string
  description = "The AWS account ID of the Workload account to create the DNS zone in"
}

variable "prime_role_name" {
  type = string
}

variable "dns_zone_name" {
  type = string
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

variable "terraform_state_region" {
  type    = string
  default = ""
}

variable "workload_dns_zone_name" {
  type    = string
  default = ""
}
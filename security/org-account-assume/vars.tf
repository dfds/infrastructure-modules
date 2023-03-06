#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}
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

variable "prime_role_max_session_duration" {
  type    = string
  default = 7200 # 2 hours
}

variable "email" {
  type = string
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "adfs_fqdn" {
  type        = string
  description = "The fully-qualified domain name of the ADFS server, e.g. adfs.company.tld"
}

variable "cloudengineer_iam_role_name" {
  description = "Name of IAM role"
  type        = string
}

variable "cloudadmin_iam_role_name" {
  description = "Name of IAM role"
  type        = string
}

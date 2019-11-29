#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
}

# variable "aws_assume_role_arn" {
#   type = "string"
#   description = "The ARN of the role to assume, for creating the account"
# }

variable "master_account_id" {
  type        = "string"
  description = "The AWS account ID of the Organizations Master account"
}

variable "core_account_id" {
  type        = "string"
  description = "The AWS account ID of the Organizations Core account"
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

variable "adfs_fqdn" {
  type        = "string"
  description = "The fully-qualified domain name of the ADFS server, e.g. adfs.company.tld"
}

variable "context_id" {
  type        = "string"
  description = "The ID of the context, for which to create and AWS account"
}

variable "correlation_id" {
  type = "string"
}

variable "capability_root_id" {
  type = "string"
}

variable "capability_name" {
  type = "string"
}

variable "capability_id" {
  type = "string"
}

variable "context_name" {
  type = "string"
}

variable "kafka_broker" {
  type = "string"
}

variable "kafka_username" {
  type = "string"
}

variable "kafka_password" {
  type = "string"
}

variable "publish_message" {
  default = true
}

variable "parent_id" {
  type        = "string"
  description = "The ID of the parent AWS Organization OU."
  default     = ""
}

variable "kiam_role_arn" {
  type = "string"
  description = "Optional: The KIAM role ARN that can assume roles"
  default = ""
}
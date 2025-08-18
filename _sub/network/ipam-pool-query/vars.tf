variable "aws_region" {
  type        = string
  description = "The AWS region to use for the IPAM pool query."
  default     = "eu-west-1"
  validation {
    condition     = can(regex("^(eu-central-1|eu-west-1)$", var.aws_region))
    error_message = "Region must be either 'eu-central-1' or 'eu-west-1'"
  }
}

variable "ipam_pool_description" {
  type        = string
  description = "The description of the IPAM pool for AWS IPAM assignment. Used to filter out the correct pool."
}

variable "ipam_cidr_prefix" {
  description = "The CIDR block prefix to use for IPAM assignment"
  type        = number
  default     = 20
  validation {
    condition     = var.ipam_cidr_prefix >= 16 && var.ipam_cidr_prefix <= 20
    error_message = "The CIDR block prefix must be a valid number, and have a value between 16 and 20 (inclusive)."
  }
}

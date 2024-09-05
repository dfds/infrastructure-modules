variable "aws_region" {
  type = string
}

variable "network_account_id" {
  type        = string
  description = "The AWS account ID of the account to which you are delegating to become IPAM admin."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

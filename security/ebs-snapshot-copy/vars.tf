variable "aws_region" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "aws_assume_role_arn" {
  type = string
}

variable "destination_accounts" {
  description = "The destination account IDs for the EBS snapshot copy."
  type        = list(string)
  default     = []
}
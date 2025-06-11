
variable "docker_username" {
  type        = string
  sensitive   = true
  description = "Username for pulling images from Docker Hub."
}

variable "docker_token" {
  type        = string
  description = "Access token for pulling images from Docker Hub."
}

variable "aws_org_id" {
  type        = string
  description = "AWS Organization ID for policies for access to ECR pull-through cache."
  validation {
    condition     = can(regex("^o-[0-9a-z]{10,11}$", var.aws_org_id))
    error_message = "AWS Organization ID must be a 12-character string starting with o-."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where the ECR pull-through cache will be created."
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format 'eu-central-1', 'eu-west-1', etc."
  }
}

variable "aws_workload_account_id" {
  description = "The ID of the account trusted to assume the role"
  type        = string
}

variable "prime_role_name" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "data_tags" {
  type        = map(string)
  description = "A map of tags to apply to all the data and/or storage deployed by the module"
  default     = {}
}

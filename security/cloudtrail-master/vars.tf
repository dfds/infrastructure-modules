#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "cloudtrail_central_s3_bucket" {
  type = string
}

variable "deploy" {
  type = bool
}

variable "log_group_retention_in_days" {
  type        = number
  description = "Number of days to retain records within the CloudWatch log group."
  default     = 7
}

variable "kms_key_user_accounts" {
  type    = list(string)
  default = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "aws_region" {
  type = string
}

variable "preventive_policy_attach_targets" {
  type = list(string)
}

variable "integrity_policy_attach_targets" {
  type = list(string)
}

variable "restrictive_policy_attach_targets" {
  type = list(string)
}

variable "reservation_policy_attach_targets" {
  type = list(string)
}

variable "resource_owner_tag_value" {
  type = string
}

variable "ec2_exempted_accounts" {
  type    = list(string)
  default = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

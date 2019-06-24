variable "name" {
  type = "string"
}

variable "org_role_name" {
  type = "string"
}

variable "email" {
  type = "string"
}

variable "sleep_after" {
  default = 0
}

variable "parent_id" {
  type        = "string"
  description = "The ID of the destination AWS Organization OU."
  default     = ""
}

variable "master_account_id" {
  type        = "string"
  description = "The AWS account ID of the Organizations Master account"
  default     = ""
}

variable "prime_role_name" {
  type    = "string"
  default = ""
}

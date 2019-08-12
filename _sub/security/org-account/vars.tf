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
  description = "The ID of the parent AWS Organization OU. Defaults to the root."
  default     = "r-65k1"                                                          # TODO: Get from data source, once supported
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

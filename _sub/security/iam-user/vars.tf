variable "user_name" {
  type = string
}

variable "group_memberships" {
  type        = list(string)
  description = "The list of group names the user belongs to."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM user."
  default     = {}
}

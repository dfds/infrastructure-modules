variable "user_name" {
  type = string
}

variable "group_memberships" {
  type        = list(string)
  description = "The list of group names the user belongs to."
  default     = []
}

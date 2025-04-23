variable "ou_name" {
  type        = string
  description = "The name of the organization unit to be managed."
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent organization unit if different than root."
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "The AWS region to use."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the organization unit."
}

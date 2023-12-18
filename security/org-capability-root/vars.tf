variable "aws_region" {
  type = string
}

variable "capability_ou_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

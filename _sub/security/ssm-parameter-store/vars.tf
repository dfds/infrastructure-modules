# Parameter key name for parameter store
variable "key_name" {
  type = string
}

# Parameter description
variable "key_description" {
  type = string
}

# Parameter value or "content"
variable "key_value" {
  type = string
}

variable "deploy" {
  type    = bool
  default = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to the ssm parameter"
  default     = {}
}

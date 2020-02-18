# Parameter key name for parameter store
variable "key_name" {
}

# Parameter description
variable "key_description" {
}

# Parameter value or "content"
variable "key_value" {
}

variable "deploy" {
  type    = bool
  default = true
}

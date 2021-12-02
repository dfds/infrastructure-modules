# Parameter key name for parameter store
variable "key_name" {
}

# Parameter description
variable "key_description" {
}

# Parameter was created by what or whom; used to populate the createdBy tag
variable "tag_createdby" {
  default = "not-specified"
}

# Parameter value or "content"
variable "key_value" {
}

variable "deploy" {
  type    = bool
  default = true
}

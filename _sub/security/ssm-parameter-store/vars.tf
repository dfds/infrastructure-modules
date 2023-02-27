# Parameter key name for parameter store
variable "key_name" {
  type = string
}

# Parameter description
variable "key_description" {
  type = string
}

# Parameter was created by what or whom; used to populate the createdBy tag
variable "tag_createdby" {
  type    = string
  default = "not-specified"
}

# Parameter value or "content"
variable "key_value" {
  type = string
}

variable "deploy" {
  type    = bool
  default = true
}

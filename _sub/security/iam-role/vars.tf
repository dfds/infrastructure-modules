variable "role_name" {
  type = "string"
}

variable "role_description" {
  type = "string"
  default = ""
}

variable "assume_role_policy" {
  type = "string"
}
variable "role_policy_name" {
  type = "string"
}
variable "role_policy_document" {
  type = "string"
}
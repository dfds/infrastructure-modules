variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "policy" {
  type = string
}

variable "attach_targets" {
  type = list(string)
}


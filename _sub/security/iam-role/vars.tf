variable "role_name" {
  type = string
}

variable "role_path" {
  type    = string
  default = "/"
}

variable "max_session_duration" {
  description = "The maximum time a role session can last, before requiring re-authentication. Default is  1 hour. "
  default     = 3600
}

variable "role_description" {
  type    = string
  default = ""
}

variable "assume_role_policy" {
  type = string
}

variable "role_policy_name" {
  type = string
}

variable "role_policy_document" {
  type = string
}


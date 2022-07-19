variable "user_name" {
  type = string
}

variable "user_policy_name" {
  type = string
}

variable "user_policy_document" {
  type = string
}

variable "create_aws_iam_access_key" {
  type = bool
  default = true
}
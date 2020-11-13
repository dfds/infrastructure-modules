variable "name" {
  type        = string
  description = "Namespace name"
}

variable "iam_roles" {
  type        = string
  description = "IAM roles allowed to assume inside namespace"
  default     = ""
}

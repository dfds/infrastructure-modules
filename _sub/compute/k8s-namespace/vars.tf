variable "name" {
  type        = string
  description = "Namespace name"
}

variable "iam_roles" {
  type        = string
  description = "IAM roles allowed to assume inside namespace"
  default     = ""
  validation {
    condition = var.iam_roles == "" ? true : (
      can(regex("^arn:aws:iam::", var.iam_roles))
    )
    error_message = "The value must contain full role ARNs."
  }
}

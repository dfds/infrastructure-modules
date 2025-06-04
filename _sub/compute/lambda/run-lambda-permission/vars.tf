variable "function_name" {
  type = string
}

variable "principal" {
  type = string
}

variable "source_arn" {
  type = string
}

variable "lambda_alias_name" {
  type        = string
  description = "The name of the lambda alias"
  default     = null
}

variable "aws_region" {
  type = string
}

variable "ou_ids_for_preventive_policy" {
  type = list(string)
}

variable "ou_ids_for_integrity_policy" {
  type = list(string)
}

variable "ou_ids_for_restrictive_policy" {
  type = list(string)
}

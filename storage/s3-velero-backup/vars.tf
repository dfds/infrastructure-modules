variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = ""
}

variable "kiam_server_role_arn" {
  type        = list(string)
  default     = [""]
  description = ""
}

variable "versioning" {
  type        = bool
  default     = true
  description = ""
}

variable "velero_iam_role_name" {
  type = string
  default = "VeleroBackup"
  description = ""
}

variable "force_bucket_destroy" {
  type        = bool
  default     = true
  description = "Destroy bucket without error"
}

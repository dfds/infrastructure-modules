variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Velero storage bucket name"
}

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type = map(string)
  default = {}
}

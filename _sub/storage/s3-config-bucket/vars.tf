variable "s3_bucket" {
  type        = string
  description = "The name of the S3 Bucket where the AWS Config inventory will be stored."
}

variable "create_s3_bucket" {
  type    = bool
  default = false
}


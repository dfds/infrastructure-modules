variable "s3_bucket" {
  description = "The name of the S3 Bucket."
}
variable "allowed_iam_arns" {
  type = list
  default = []
}

variable "enable_versioning" {
  default = false
}

variable "enable_destroy" {
  default = false
}

variable "bucket_canned_acl" {
  default = "private"
  description = "Use one of the predefined grants. For more information: https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"
}

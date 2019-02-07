variable "s3_bucket" {
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}

variable "create_s3_bucket" {
  default = false
}
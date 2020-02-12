variable "s3_bucket" {
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}

variable "retention_days" {
  description = "The number of days to keep CloudTrail logs in s3 bucket."
  default     = 90
}

variable "create_s3_bucket" {
  default = false
}


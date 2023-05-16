variable "s3_bucket" {
  type        = string
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}

variable "retention_days" {
  type        = number
  description = "The number of days to keep CloudTrail logs in s3 bucket."
  default     = 90
}

variable "create_s3_bucket" {
  type    = bool
  default = false
}

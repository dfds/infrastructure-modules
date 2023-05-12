variable "s3_bucket" {
  type        = string
  description = "The name of the S3 bucket where CloudTrail logs will be stored."
}

variable "s3_log_bucket" {
  type        = string
  description = "The name of the S3 bucket where server access logs for the bucket with the CloudTrail logs will be stored."
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


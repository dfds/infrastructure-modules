variable "aws_region" {
  description = "The AWS Region in which the s3 bucket will be created."
}

variable "cloudtrail_s3_bucket" {
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}

variable "cloudtrail_logs_retention" {
  description = "The number of days to keep CloudTrail logs in s3 bucket."
  default = 90
}



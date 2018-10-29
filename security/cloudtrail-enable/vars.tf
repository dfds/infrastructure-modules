variable "aws_region" {
  description = "The AWS Region in which the CloudTrail Trail will be created. Note that API data will be captured from all AWS regions if var.is_multi_region_trail is true."
}

variable "aws_account_name" {
  description = "The AWS account alias"
}

variable "cloudtrail_s3_bucket" {
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}

variable "s3_bucket_already_exists" {
  description = "If set to true, that means the S3 bucket you're using already exists, and does not need to be created. This is especially useful when using CloudTrail with multiple AWS accounts, with a common S3 bucket shared by all of them."
  default     = false
}

variable "enable_cloudtrail" {
  description = "Enables logging for the trail. Setting this to false will pause logging. (true or false)"
  default     = true
}

variable "cloudtrail_trail_name" {
  description = "The name to assign to the CloudTrail 'trail' that will be used to track all API calls in your AWS account."
  default     = "full-account"
}

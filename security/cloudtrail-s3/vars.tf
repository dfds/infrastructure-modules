variable "aws_region" {
  description = "The AWS Region in which the CloudTrail Trail will be created. Note that API data will be captured from all AWS regions if var.is_multi_region_trail is true."
}

variable "s3_bucket_name" {
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}


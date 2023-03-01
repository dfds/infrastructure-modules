variable "deploy" {
  description = "Configure Cloud Trail feature toggle."
  type        = bool
  default     = true
}

variable "s3_bucket" {
  type        = string
  description = "The name of the S3 Bucket where CloudTrail logs will be stored."
}

variable "trail_name" {
  type        = string
  description = "The name to assign to the CloudTrail 'trail' that will be used to track all API calls in your AWS account."
}

variable "is_organization_trail" {
  type        = bool
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts"
  default     = false
}

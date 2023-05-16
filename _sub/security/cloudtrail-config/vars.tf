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

variable "create_log_group" {
  type        = bool
  description = "Specifies whether a CloudWatch log group should be created for the logs to be forwarded to."
  default     = false
}

variable "create_kms_key" {
  type        = bool
  description = "Specifies whether a KMS customer-managed key should be created for the enabling server side encryption on the CloudTrail logs."
  default     = false
}

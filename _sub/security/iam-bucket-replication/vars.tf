variable "role_name" {
  type        = string
  description = "Name of the role to create"
}

variable "policy_name" {
  type        = string
  description = "Name of the IAM policy to create"
}

variable "s3_source_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to allow replication from"
}

variable "s3_destination_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to allow replication to"
}

variable "kms_key_source_arn" {
  type        = string
  description = "The ARN of the KMS key to allow decryption of the source bucket"
}

variable "kms_key_destination_arn" {
  type        = string
  description = "The ARN of the KMS key to allow encryption of the destination bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the role"
}

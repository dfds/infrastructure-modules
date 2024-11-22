variable "replication_source_role_name" {
  type        = string
  description = "Name of the role to create"
}

variable "replication_source_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to allow replication from"
}

variable "replication_destination_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to allow replication to"
}

variable "replication_source_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to allow decryption of the source bucket"
}

variable "replication_destination_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to allow encryption of the destination bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the role"
}

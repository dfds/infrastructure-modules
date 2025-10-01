#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "aws_region_2" {
  type        = string
  description = "Terraform has limitations that prevent us from dynamically creating AWS providers for each region, so instead of providing a list of regions we will specifiy an incremented set of variables to deploy resources across multiple regions."
  default     = "eu-west-1"
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent AWS Organization OU. Defaults to the root."
  default     = "r-65k1"
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "create_cloudtrail_s3_bucket" {
  type    = bool
  default = false
}

variable "cloudtrail_central_s3_bucket" {
  type = string
}

variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
}

variable "security_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Security account"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "steampipe_audit_role_name" {
  type        = string
  description = "Name of the IAM role used by Steampipe for reading resources"
  default     = "steampipe-audit"
}

variable "cloudtrail_replication_enabled" {
  type        = bool
  description = "Enable S3 bucket replication."
  default     = false
}

variable "cloudtrail_replication_destination_account_id" {
  type        = string
  description = "The account ID of the destination bucket."
  default     = null
}

variable "cloudtrail_replication_destination_bucket_arn" {
  type        = string
  description = "The ARN of the destination bucket."
  default     = null
}

variable "cloudtrail_replication_source_role_name" {
  type        = string
  description = "Name of the role to create"
  default     = null
}

variable "cloudtrail_replication_source_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to allow decryption of the source bucket"
  default     = null
}

variable "cloudtrail_replication_destination_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to allow encryption of the destination bucket"
  default     = null
}

variable "aws_region" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "aws_assume_role_arn" {
  type = string
}

variable "shared_snapshot_source_account" {
  description = "The source account ID from which the EBS snapshots are shared."
  type        = string
  default     = ""
}

variable "snapshot_share_kms_arn" {
  description = "The KMS key ARN to use for copying snapshots if encryption is used."
  type        = string
  default     = ""
}
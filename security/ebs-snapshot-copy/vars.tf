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

variable "snapshot_share_destination_accounts" {
  description = "The destination account IDs for the EBS snapshot copy."
  type        = list(string)
  default     = []
}

variable "snapshot_share_kms_arn" {
  description = "The KMS key ARN to use for copying snapshots if encryption is used."
  type        = string
  default     = ""
}
variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Velero storage bucket name"
}

variable "kiam_server_role_arn" {
  type        = list(string)
  default     = [""]
  description = "Role to allow for trust relationship to KIAM "
}

variable "versioning" {
  type        = bool
  default     = true
  description = "Enable S3 bucket versioning"
}

variable "velero_iam_role_name" {
  type        = string
  default     = "VeleroBackup"
  description = "Velero role for S3 actions"
}

variable "force_bucket_destroy" {
  type        = bool
  default     = true
  description = "Destroy bucket without error"
}

variable "oidc_provider_server_id" {
  type        = string
  default     = null
  description = "The FQDN and ID of the OIDC provider"
}

variable "oidc_provider_account_id" {
  type        = string
  default     = null
  description = "The AWS account ID that owns the OIDC provider"
}

variable "namespace" {
  type        = string
  default     = "velero"
  description = "The namespace that Velero will be installed to"
}

variable "service_account" {
  type        = string
  default     = "velero-server"
  description = "The service account to be used by Velero"
}

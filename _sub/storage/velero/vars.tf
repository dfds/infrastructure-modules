variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name for writing Flux manifests to."
}

variable "repo_branch" {
  type        = string
  description = "The git branch."
}

variable "bucket_arn" {
  type        = string
  description = "The arn of the S3 bucket that contains the Velero backup."
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the S3 bucket is located"
}

variable "gitops_apps_repo_url" {
  type        = string
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  description = "The default branch or tag for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "oidc_issuer" {
  type        = string
  description = "The OIDC issuer for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  description = "The workload account ID."
}

variable "access_mode" {
  type        = string
  description = "Access mode for Velero backups. Can be 'ReadWrite' or 'ReadOnly'"
  validation {
    condition     = contains(["ReadWrite", "ReadOnly"], var.access_mode)
    error_message = "The access_mode must be either 'ReadWrite' or 'ReadOnly'."
  }
}

variable "ebs_csi_kms_arn" {
  type        = string
  default     = ""
  description = "The ARN of the KMS key used for EBS CSI encryption"
}

variable "azure_resource_group_name" {
  type        = string
  description = "The name of the Azure resource group where the storage account is located"
}

variable "azure_storage_account_name" {
  type        = string
  description = "The name of the Azure storage account where the Velero backups will be stored"
}

variable "azure_subscription_id" {
  type        = string
  description = "The Azure subscription ID where the storage account is located"
}

variable "azure_bucket_name" {
  type        = string
  description = "The name of the Azure storage container where Velero backups will be stored"
}

variable "velero_ssm_role_arn" {
  type        = string
  description = "The IAM role for the Velero service account to assume for accessing AWS SSM Parameter Store"
}

variable "cluster_backup_disabled" {
  type        = bool
  default     = false
  description = "Disable cluster-scoped resource backups"
}

variable "cluster_backup_offsite_disabled" {
  type        = bool
  default     = false
  description = "Disable offsite backups for cluster-scoped resources"
}

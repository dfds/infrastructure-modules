variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "velero"
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name for writing Flux manifests to."
}

variable "repo_branch" {
  type        = string
  default     = "main"
  description = "The git branch."
}

variable "bucket_arn" {
  type        = string
  default     = null
  description = "The arn of the S3 bucket that contains the Velero backup. Only used if S3 bucket is in a different account"
}

variable "bucket_region" {
  type        = string
  default     = "eu-west-1"
  description = "The region in which the S3 bucket that contains the Velero backup has been created"
}

variable "snapshots_enabled" {
  type        = bool
  default     = false
  description = "Should Velero use snapshot backups?"

}

variable "log_level" {
  type        = string
  default     = "info"
  description = "Velero log level."
  validation {
    condition     = contains(["info", "debug", "warning", "error", "fatal", "panic"], var.log_level)
    error_message = "Invalid value for log_level. Valid values: info, debug, warning, error, fatal, panic."
  }
}

variable "cron_schedule" {
  type        = string
  default     = "0 0 * * *"
  description = "Cron-formatted scheduled time."
}

variable "schedules_template_ttl" {
  type        = string
  default     = "336h"
  description = "Time to live for the scheduled backup."
}

variable "schedules_template_include_cluster_resources" {
  type        = bool
  default     = false
  description = "Should Velero also backup cluster resources?"
}

variable "helm_repo_name" {
  type        = string
  default     = "vmware-tanzu"
  description = "The name of the Helm repo with the Velero Helm chart"
}

variable "helm_chart_version" {
  type        = string
  default     = ""
  description = "The Velero Helm chart version to install"
}

variable "image_tag" {
  type        = string
  default     = "v1.12.4"
  description = "Override the image tag in the Helm chart with a custom version"
}

variable "plugin_for_aws_version" {
  type        = string
  description = "The version of velero-plugin-for-aws to use as initContainer"
  validation {
    condition     = can(regex("^v[[:digit:]].[[:digit:]].[[:digit:]]+", var.plugin_for_aws_version))
    error_message = "Velero plugin for AWS must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "plugin_for_csi_version" {
  type        = string
  description = "The version of velero-plugin-for-csi to use as initContainer"
  validation {
    condition     = can(regex("^v[[:digit:]].[[:digit:]].[[:digit:]]+", var.plugin_for_csi_version))
    error_message = "Velero plugin for CSI must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "velero_iam_role_name" {
  type        = string
  default     = "VeleroBackup"
  description = "Velero role for S3 actions"
}

variable "service_account" {
  type        = string
  default     = "velero-server"
  description = "The service account to be used by Velero"
}

variable "namespace" {
  type        = string
  default     = "velero"
  description = "The namespace where Velero should be installed"
}

variable "oidc_issuer" {
  type        = string
  default     = null
  description = "The OIDC isssue for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  default     = null
  description = "The workload account ID."
}

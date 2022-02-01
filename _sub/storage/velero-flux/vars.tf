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

variable "github_owner" {
  type        = string
  description = "The GitHub organization owner."
}

variable "role_arn" {
  type        = string
  description = "The ARN for the role that is permitted to use Velero backup storage."
  default     = null
}

variable "bucket_name" {
  type        = string
  default     = null
  description = "The name of the S3 bucket that contains the Velero backup"
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
  description = "Cron format scheuled time."
}

variable "schedules_template_ttl" {
  type        = string
  default     = "336h"
  description = "Time to live for the scheduled backup."
}

variable "schedules_template_snapshot_volumes" {
  type        = bool
  default     = false
  description = "Should Velero use snapshot volumes?"
}

variable "schedules_template_include_cluster_resources" {
  type        = bool
  default     = false
  description = "Should Velero also backup cluster resources?"
}


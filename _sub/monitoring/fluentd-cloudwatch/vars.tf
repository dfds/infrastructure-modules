variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "fluentd-cloudwatch"
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

variable "aws_region" {
  type        = string
  description = "Which AWS region to store the cloudwatch logs in."
}

variable "account_id" {
  type        = string
  description = "The account id that owns the cloudwatch logs from fluentd."
}

variable "retention_in_days" {
  type        = string
  default     = "7"
  description = "How many days to keep the logs?"
}

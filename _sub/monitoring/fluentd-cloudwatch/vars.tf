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

variable "aws_workload_account_id" {
  description = "The account id for the account that owns the cluster."
}

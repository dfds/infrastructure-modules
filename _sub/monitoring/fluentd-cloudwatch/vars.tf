variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "fluentd-cloudwatch"
}

variable "repo_name" {
  type        = string
  description = ""
}

variable "repo_branch" {
  type        = string
  default     = "main"
  description = ""
}

variable "github_owner" {
  type        = string
  description = ""
}

variable "aws_region" {
  type = string
}

variable "aws_workload_account_id" {
}

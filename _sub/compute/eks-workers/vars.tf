variable "cluster_name" {
  type = string
}

variable "cloudwatch_agent_config_bucket" {
  type = string
}

variable "cur_bucket_arn" {
  type        = string
  default     = null
  description = "S3 ARN for Billing Cost and Usage Report (CUR)"
}

# --------------------------------------------------
# IAM role for Grafana Cloud Cloudwatch integration
# --------------------------------------------------

variable "iam_role" {
  type = object({
    arn       = string
    stack_ids = list(string)
  })
  description = "IAM role used for Grafana Cloud IAM CloudWatch access"
  default     = null
}

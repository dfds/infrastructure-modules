variable "chart_version" {
  type        = string
  description = "aws-ebs-csi-driver helm chart version"
  default     = null
}

variable "cluster_name" {
  type = string
  description = "aws-ebs-csi-driver helm chart version"
}

variable "kiam_server_role_arn" {
  type        = string
  description = "The role or entity to provide trust for when creating roles to use with annotations in kubernetes"
}

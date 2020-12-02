variable "chart_version" {
  type        = string
  description = "aws-ebs-csi-driver helm chart version"
  default     = null
}

variable "rolename" {
  type        = string
  description = "Role name to be used when for the AWS EKS CSI driver"
}

variable "cluster_name" {
  type = string
}

variable "aws_workload_account_id" {
}

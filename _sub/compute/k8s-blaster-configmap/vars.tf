variable "deploy" {
  default = true
}

variable "aws_assume_role_arn" {
  default = ""
}

variable "cluster_name" {}

variable "configmap_key" {}

variable "s3_bucket" {}

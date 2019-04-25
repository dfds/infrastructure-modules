variable "cluster_name" {}

variable "eks_endpoint" {}

variable "eks_certificate_authority" {}

variable "eks_role_arn" {}

variable "aws_assume_role_arn" {}

variable "blaster_configmap_apply" {
  default = false
}

variable "blaster_configmap_s3_bucket" {}

variable "blaster_configmap_key" {}

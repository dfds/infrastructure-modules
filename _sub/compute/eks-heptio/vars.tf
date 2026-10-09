variable "cluster_name" {
  type = string
}

variable "eks_endpoint" {
  type = string
}

variable "eks_certificate_authority" {
  type = string
}

variable "eks_role_arn" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}


variable "blaster_configmap_s3_bucket" {
  description = "The S3 bucket where the blaster configmap is stored. If empty default ConfigMap will be applied. If the bucket or object `var.blaster_configmap_key` specified does not exist, the default ConfigMap will also be used."
  type        = string
}

variable "blaster_configmap_key" {
  type = string
}

variable "kubeconfig_path" {
  type = string
}

variable "eks_k8s_auth_api_version" {
  description = "The fully qualified version of the client authentication API."
  type        = string
  default     = "client.authentication.k8s.io/v1beta1"
}

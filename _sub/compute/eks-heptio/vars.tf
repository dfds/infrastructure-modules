variable "cluster_name" {
}

variable "eks_endpoint" {
}

variable "eks_certificate_authority" {
}

variable "eks_role_arn" {
}

variable "aws_assume_role_arn" {
}

variable "blaster_configmap_apply" {
  type    = bool
  default = false
}

variable "blaster_configmap_s3_bucket" {
}

variable "blaster_configmap_key" {
}

variable "kubeconfig_path" {
  type = string
}

variable "eks_k8s_auth_api_version" {
  description = "The fully qualified version for the client authentication API."
  type        = string
  default     = "client.authentication.k8s.io/v1alpha1"
}

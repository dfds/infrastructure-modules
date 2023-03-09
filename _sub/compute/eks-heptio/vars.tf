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

variable "blaster_configmap_apply" {
  type    = bool
  default = false
}

variable "blaster_configmap_s3_bucket" {
  type = string
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

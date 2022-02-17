variable "aws_account_id" {
  type        = string
  description = "Used for iam policy oidc trust"
}

variable "aws_region" {
  type = string
  description = "Used to filter subnets by AWS region"
}

variable "oidc_issuer" {
  type        = string
  description = "Used for iam policy oidc trust"
  validation {
    condition     = substr(var.oidc_issuer, 0, 8) != "https://"
    error_message = "Oidc_issuer may not contain https:// in the start of the variable."
  }
}

variable "namespace_name" {
  type = string
  description = "K8s namespace for deployment/iam policy"
}

variable "image_tag" {
  type = string
  description = "K8s subnet-exporter image tag"
}

variable "oidc_issuer" {
  type        = string
  default     = null
  description = "The OIDC isssue for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  default     = null
  description = "The workload account ID."
}

variable "aws_region" {
  type = string
}

variable "iam_role_name" {
  type        = string
  description = "The name of the IAM role to assume"
  default     = "ssm-secrets-for-kubernetes"
}

variable "service_account" {
  type        = string
  default     = "ssm-secrets"
  description = "The service account to be used by an SecretStore"
}

variable "allowed_namespaces" {
  type        = list(string)
  default     = []
  description = "The namespaces that can use IRSA to access external secrets"
}

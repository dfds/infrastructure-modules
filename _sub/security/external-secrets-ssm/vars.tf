variable "oidc_issuer" {
  type        = string
  description = "The OIDC issuer for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  description = "The workload account ID."
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster"
}

variable "service_account" {
  type        = string
  description = "The service account to be used by an SecretStore"
}

variable "allowed_namespaces" {
  type        = list(string)
  description = "The namespaces that can use IRSA to access external secrets"
}

variable "kubeconfig_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = null
}

variable "chart_version" {
  type        = string
  description = "The Helm chart version to deploy"
}

# Currently only needed for IAM policy. Convert this to inline policy, ditch cluster name from policy name and remove this variable?
variable "cluster_name" {
  type        = string
  description = "The cluster name"
}

variable "kiam_server_role_arn" {
  type        = string
  description = "The role or entity to provide trust for when creating roles to use with annotations in kubernetes"
}

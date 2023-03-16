variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "container_runtime" {
  type        = string
  description = "The container runtime utilized within the EKS cluster."

  validation {
    condition     = contains(["dockerd", "containerd"], var.container_runtime)
    error_message = "Valid values for var.container_runtime are dockerd and containerd."
  }
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "fluentd-cloudwatch"
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name for writing Flux manifests to."
}

variable "repo_branch" {
  type        = string
  default     = "main"
  description = "The git branch."
}

variable "aws_region" {
  type        = string
  description = "Which AWS region to store the cloudwatch logs in."
}

variable "retention_in_days" {
  type        = string
  default     = "7"
  description = "How many days to keep the logs?"
}

variable "eks_openid_connect_provider_url" {
  type        = string
  description = "EKS OIDC issuer url"
}

variable "deploy_oidc_provider" {
  type        = bool
  description = "Create an OIDC provider only if external log account is provided"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

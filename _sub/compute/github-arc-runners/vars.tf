variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "arc-runner-set"
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "arc-runners"
}

variable "github_owner" {
  type        = string
  description = "Name of the Github owner (previously: organization)"
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
  default     = null
}

variable "helm_chart_version" {
  type        = string
  description = "The version of the chart that should be used"
  default     = ""
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

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "github_config_url" {
  type = string
  description = "URL of Github organisation or repo for the runners"
}

variable "github_config_secret" {
  type = string
  description = "Secret name containing authorisation information for the runners. This is not deployed by this module, consider using external-secrets to deploy it"
}

variable "runner_scale_set_name" {
  type = string
  description = "Name for the runner scale set"
}

variable "storage_class_name" {
  type = string
  description = "Name of the storage class to use for the runners persistent volume"
  default = "csi-gp3"
}

variable "storage_request_size" {
  type = string
  description = "Size of the persistent volume claim for the runners"
  default = "1Gi"
}

variable "controller_deploy_name" {
  type        = string
  description = "Name of the controller deployment so we can depend on it before trying to install the runner"
  default     = "platform-apps-arc-helm"
}

variable "min_runners" {
  type = number
  description = "Minimum number of runners to keep running"
  default = 0
}

variable "max_runners" {
  type = number
  description = "Maximum number of runners to keep running"
  default = 5
}
  
variable "runner_memory_request" {
  type = string
  description = "Memory request for the runner pods"
  default = "128Mi"
}

variable "runner_memory_limit" {
  type = string
  description = "Memory request for the runner pods"
  default = "8Gi"
}
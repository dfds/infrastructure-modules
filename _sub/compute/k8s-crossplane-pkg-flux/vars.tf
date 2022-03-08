## Crossplane Configuration Deployment ##

variable "repo_owner" {
  type        = string
  description = "Github username or organization that owns the repo to store the Flux manifests in"
  default     = null
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the Flux manifests in"
  default     = null
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the Flux repo (optional)"
  default     = "main"
}

variable "cluster_name" {
  type = string
}

variable "name" {
  type        = string
  description = "The configuration name. Default: dfds-infra"
  default     = "dfds-infra"
}

variable "package" {
  type        = string
  description = "The Docker image address the crossplane configuration we want to deploy, e.g.: dfdsdk/dfds-infra:v0.0.1"
  default     = null
}

variable "package_pull_policy" {
  type        = string
  description = "PackagePullPolicy defines the pull policy for the package. Default is: IfNotPresent."
  default     = "IfNotPresent"
  validation {
    condition     = var.package_pull_policy == "Always" || var.package_pull_policy == "IfNotPresent"
    error_message = "The PackagePullPolicy must be Always or IfNotPresent."
  }
}

variable "revision_activation_policy" {
  type        = string
  description = "RevisionActivationPolicy specifies how the package controller should update from one revision to the next. Default is: Automatic."
  default     = "Automatic"
  validation {
    condition     = var.revision_activation_policy == "Automatic" || var.revision_activation_policy == "Manual"
    error_message = "The RevisionActivationPolicy must be Automatic or Manual."
  }
}

variable "revision_history_limit" {
  type        = number
  description = "RevisionHistoryLimit dictates how the package controller cleans up old inactive package revisions. Defaults to 1. Can be disabled by explicitly setting to 0."
  default     = 1
}


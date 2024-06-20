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

variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "grafana"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
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
  type = string
  #   default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "namespace" {
  type        = string
  description = "Namespace to apply monitoring components in"
  default     = "grafana"
  validation {
    condition     = can(regex("[a-z]+", var.namespace))
    error_message = "Namespace must contain at least one letter."
  }
}

variable "chart_version" {
  type        = string
  description = "Grafana Agent helm chart version"
  default     = ""
}

variable "storage_enabled" {
  type        = bool
  default     = false
  description = "Enable persistence for Write Ahead Logs (WAL) in Grafana using Persistent Volume Claims"
}

variable "agent_resource_memory_request" {
  type        = string
  default     = null
  description = "Set resource memory request on Grafana Agent container"
}

variable "agent_resource_memory_limit" {
  type        = string
  default     = null
  description = "Set resource memory limits on Grafana Agent container"
}

variable "tolerations" {
  type = list(object({
    key      = string,
    operator = string,
    value    = optional(string),
    effect   = string,
  }))
  default = []
}

variable "affinity" {
  type = list(object({
    key      = string,
    operator = string,
    values   = list(string)
  }))
  default = []
}

variable "agent_replicas" {
  type        = number
  default     = 1
  description = "How many replicas to run Grafana Agent with"
}

variable "storage_class" {
  type        = string
  description = "Storage class for Grafana Persistent Volume"
  default     = "csi-gp3"
}

variable "storage_size" {
  type        = string
  description = "Storage size for Grafana Persistent Volume"
  default     = "5Gi"
}

variable "api_token" {
  type        = string
  description = "The token to authenticate request to a Grafana Cloud stack"
  default     = null
  sensitive   = true
  validation {
    condition     = var.api_token != null || can(regex("^(glc\\_)+", var.api_token))
    error_message = "The value for var.api_token must start with glc_"
  }
}

variable "prometheus_url" {
  type        = string
  description = "The Prometheus URL in a Grafana Cloud stack"
  default     = null
  validation {
    condition     = var.prometheus_url != null || can(regex("^(https:\\/\\/)+", var.prometheus_url))
    error_message = "The value for var.prometheus_url must start with https://"
  }
}

variable "prometheus_username" {
  type        = string
  description = "The username for Prometheus in a Grafana Cloud stack"
  default     = null
  validation {
    condition     = var.prometheus_username != null || length(var.prometheus_username) > 0
    error_message = "The value for var.prometheus_username must be defined"
  }
}

variable "loki_url" {
  type        = string
  description = "The Loki URL in a Grafana Cloud stack"
  default     = null
  validation {
    condition     = var.loki_url != null || can(regex("^(https:\\/\\/)+", var.loki_url))
    error_message = "The value for var.loki_url must start with https://"
  }
}

variable "loki_username" {
  type        = string
  description = "The username for Loki in a Grafana Cloud stack"
  default     = null
  validation {
    condition     = var.loki_username != null || length(var.loki_username) > 0
    error_message = "The value for var.loki_username must be defined"
  }
}

variable "tempo_url" {
  type        = string
  description = "The Tempo URL in a Grafana Cloud stack"
  default     = null
  validation {
    condition     = var.tempo_url != null || can(regex("^(https:\\/\\/)+", var.tempo_url))
    error_message = "The value for var.tempo_url must start with https://"
  }
}

variable "tempo_username" {
  type        = string
  description = "The username for Tempo in a Grafana Cloud stack"
  default     = null
  validation {
    condition     = var.tempo_username != null || length(var.tempo_username) > 0
    error_message = "The value for var.tempo_username must be defined"
  }
}

variable "traces_enabled" {
  type        = bool
  default     = true
  description = "Enable traces or not. Default: true"
}

variable "open_cost_enabled" {
  type        = bool
  description = "Enable scraping cost metrics Grafana Cloud Prometheus or not. Default: false"
  default     = false
}

variable "priority_class" {
  type        = string
  description = "Name of priority class to apply"
  default     = "cluster-monitoring" # TODO: remove default and change to monitoring_kube_prometheus_stack_priority_class
}

variable "helm_repo_url" {
  type        = string
  description = "The repository URL for the Grafana Agent Helm chart"
  default     = "https://grafana.github.io/helm-charts"
  validation {
    condition     = var.helm_repo_url != null || can(regex("^(https:\\/\\/)+", var.helm_repo_url))
    error_message = "The value for var.helm_repo_url must start with https://"
  }
}

variable "chart_version" {
  type        = string
  description = "Grafana Agent helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply Grafana Agent in"
  default     = "grafana-agent"
  validation {
    condition     = can(regex("[a-z]+", var.namespace))
    error_message = "Namespace must contain at least one letter."
  }
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Create the namespace if it does not yet exist. Default: true"
}

variable "atomic" {
  type        = bool
  default     = true
  description = "Installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Default: true"
}

variable "timeout" {
  type        = number
  default     = 120
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Default: 120"
}

variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster to install the Grafana Agent in"
  default     = "grafana-agent"
  validation {
    condition     = can(regex("[a-z]+", var.cluster_name))
    error_message = "Cluster name must contain at least one letter."
  }
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

variable "enable_side_by_side" {
  type        = bool
  default     = true
  description = "Allow Grafana Agent to be installed side by side with kube-prometheus-stack and use its CRDs and its node-exporter. Default: true"
}

variable "agent_resource_memory_limit" {
  type        = string
  default     = null
  description = "Set resource memory limits on Grafana Agent container"
}

variable "agent_resource_memory_request" {
  type        = string
  default     = null
  description = "Set resource memory request on Grafana Agent container"
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

variable "storage_enabled" {
  type        = bool
  default     = false
  description = "Enable persistence for Write Ahead Logs (WAL) in Grafana using Persistent Volume Claims"
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

variable "priority_class" {
  type        = string
  description = "Name of priority class to apply"
  default     = "cluster-monitoring" # TODO: remove default and change to monitoring_kube_prometheus_stack_priority_class
}

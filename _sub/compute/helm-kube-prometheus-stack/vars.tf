variable "cluster_name" {
  type        = string
  description = "Used to name created items such as stored password in SSM parameter store and flux paths"
}

variable "chart_version" {
  type        = string
  description = "Kube-prometheus-stack helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply Kube-prometheus-stack in"
  validation {
    condition     = can(regex("[a-z]+", var.namespace))
    error_message = "Namespace must contain at least one letter."
  }

}

variable "priority_class" {
  type        = string
  description = "Name of priority class to apply"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  sensitive   = true
}

variable "grafana_ingress_path" {
  type        = string
  description = "Grafana ingress path"
}

variable "grafana_host" {
  type        = string
  description = "Grafana ingress host"
}

variable "grafana_notifier_name" {
  type        = string
  description = "Grafana notifier name"
}

variable "grafana_iam_role_arn" {
  type        = string
  description = "Grafana IAM role ARN to add as pod annotation"
}

variable "grafana_serviceaccount_name" {
  type        = string
  description = "Grafana serviceaccount to be used for pod"
}

variable "grafana_storage_enabled" {
  type        = bool
  description = "Enable persistence in Grafana using Persistent Volume Claims"
}

variable "grafana_storage_class" {
  type        = string
  description = "Storage class for Grafana Persistent Volume"
}

variable "grafana_storage_size" {
  type        = string
  description = "Storage size for Grafana Persistent Volume"
}

variable "grafana_service_port" {
  type        = number
  description = "Grafana service port."
  default     = 80
}

variable "slack_webhook" {
  type        = string
  description = "Alert Slack webhook"
  default     = ""
}

variable "prometheus_storageclass" {
  type        = string
  description = "Prometheus storage class"
}

variable "prometheus_storage_size" {
  type        = string
  description = "Storage size for Proemtheus to use"
}

variable "prometheus_retention" {
  type        = string
  description = "How long to persist data"
}

variable "slack_channel" {
  type        = string
  description = "Alert Slack channel"
  default     = ""
}

variable "target_namespaces" {
  type        = string
  description = "Filter on namespaces"
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

variable "prometheus_request_memory" {
  type        = string
  description = "Prometheus resource setting for memory request"
  default     = "512Mi"
}

variable "prometheus_request_cpu" {
  type        = string
  description = "Prometheus resource setting for cpu request"
  default     = "500m"
}

variable "prometheus_limit_memory" {
  type        = string
  description = "Prometheus resource setting for limit memory"
  default     = "2Gi"
}

variable "prometheus_limit_cpu" {
  type        = string
  description = "Prometheus resource setting for limit cpu"
  default     = "1000m"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
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

variable "grafana_azure_tenant_id" {
  type        = string
  default     = ""
  description = "Azure Tenant ID"
}

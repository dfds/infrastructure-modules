variable "cluster_name" {
  type        = string
  description = "Used to set the trust relationship with the correct cluster's kiam-server role"
}

variable "chart_version" {
  type        = string
  description = "Kube-prometheus-stack helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply Kube-prometheus-stack in"
  default     = "monitoring"
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
  sensitive = true
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

variable "grafana_service_port" {
  type        = number
  description = "Grafana service port. See https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml"
  default     = 80
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

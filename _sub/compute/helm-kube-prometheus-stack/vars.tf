variable "aws_workload_account_id" {
  type        = string
  description = "Used to set the trust relationship with the correct account"
}

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
}

variable "priority_class" {
  type        = string
  description = "Name of priority class to apply"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  default     = ""
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

variable "grafana_iam_role_name" {
  type        = string
  description = "Name to be given to the Grafana IAM role"
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

variable "alertmanager_silence_namespaces" {
  type        = string
  description = "Silence namespaces"
}

variable "chart_version" {
  type = string
  description = "Kube-prometheus-stack helm chart version"
  default = null
}

variable "namespace" {
  type = string
  description = "Namespace to apply Kube-prometheus-stack in"
  default = "monitoring"
}

variable "priority_class" {
  type = string
  description = "Name of priority class to apply"
}

variable "deploy" {
  type = bool
  description = "Deployment switch for Kube-prometheus-stack"
}

variable "grafana_admin_password" {
  type = string
  description = "Grafana admin password"
}

variable "grafana_ingress_path" {
  type = string
  description = "Grafana ingress path"
}

variable "grafana_host" {
  type = string
  description = "Grafana ingress host"
}

variable "grafana_notifier_name" {
  type = string
  description = "Grafana notifier name"
}

variable "slack_webhook" {
  type = string
  description = ""
}

variable "prometheus_storageclass" {
  type = string
  description = ""
}

variable "prometheus_storage_size" {
  type = string
  description = ""
}

variable "prometheus_retention" {
  type = string
  description = ""
}

variable "slack_channel" {
  type = string
  description = ""
}

variable "target_namespaces" {
  type = string
  description = ""
}
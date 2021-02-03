variable "aws_workload_account_id" {
}

variable "cluster_name" {
  type = string
}

variable "worker_role_id" {
}

variable "force_update" {
  type        = bool
  description = "(optional) Force resource update through delete/recreate if needed."
  default     = true
}

variable "recreate_pods" {
  type        = bool
  description = "(optional) Perform pods restart during upgrade/rollback."
  default     = true
}

variable "agent_deep_liveness" {
  type        = bool
  description = "Fail agent liveness probe if the server is not accessible"
  default     = false
}

variable "agent_gateway_timeout" {
  type        = string
  description = "Agent's timeout when creating the kiam gateway"
  default     = "1s"
}

variable "agent_liveness_timeout" {
  type        = number
  description = "When the agent's liveness probe times out"
  default     = 1
}

variable "server_gateway_timeout" {
  type        = string
  description = "Server's timeout when creating the kiam gateway"
  default     = "1s"
}

variable "server_liveness_timeout" {
  type        = number
  description = "When the server's liveness probe times out"
  default     = 10
}

variable "server_readiness_timeout" {
  type        = number
  description = "When the server's readiness probe times out"
  default     = 10
}

variable "priority_class" {
  description = "Name of the Kubernetes priority class pods should use"
  type        = string
}

variable "agent_request_cpu" {
  type        = string
  description = "The minimum of CPU required to run the Agent pod"
  default     = "10m"
}

variable "agent_request_memory" {
  type        = string
  description = "The minimum of memory required to run the Agent pod"
  default     = "32Mi"
}

variable "server_request_cpu" {
  type        = string
  description = "The minimum of CPU required to run the Server pod"
  default     = "20m"
}

variable "server_request_memory" {
  type        = string
  description = "The minimum of memory required to run the Server pod"
  default     = "128Mi"
}

variable "chart_version" {
  type        = string
  description = "KIAM helm chart version"
  default     = null
}

variable "servicemonitor_enabled" {
  type = bool
  description = "Deploy af Prometheus servicemonitor crd to enable metrics scraping"
  default = false
}

variable "deploy" {
  type    = bool
  default = true
}

variable "aws_workload_account_id" {
}

variable "cluster_name" {
  type = string
}

variable "worker_role_id" {
}

variable "image_tag" {
  type        = string
  description = "Image tag of KIAM to deploy"
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

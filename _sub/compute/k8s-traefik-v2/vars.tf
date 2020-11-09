variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
}

variable "deploy_name" {
}

variable "namespace" {
  default = "kube-system"
}

variable "image_version" {
}

variable "replicas" {
}

variable "priority_class" {
  description = "Name of the Kubernetes priority class pods should use"
  type = string
}

variable "http_nodeport" {
  description = "Nodeport used by ALB's to connect to the Traefik instance"
  type = number
}

variable "admin_nodeport" {
  description = "Nodeport used by ALB's to connect to the Traefik instance admin page"
  type = number
}

variable "request_cpu" {
  type = string
  description = "(optional) Describes the minimum amount of CPU required"
  default = "100m"
}

variable "request_memory" {
  type = string
  description = "(optional) Describes the minimum amount of memory required"
  default = "128Mi"
}
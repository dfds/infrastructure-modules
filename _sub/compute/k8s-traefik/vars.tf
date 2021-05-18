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

variable "dashboard_deploy" {
  type        = bool
  description = "Deploy ingress for secure access to Traefik dashboard."
  default     = false
}

variable "dashboard_username" {
  type        = string
  description = "Username used for basic authentication."
  default     = "cloudengineer"
}

variable "dashboard_secret_name" {
  type        = string
  description = "Name of the k8s secret to store the credentials for basic authentication."
  default     = "traefik-basic-auth"
}

variable "dashboard_ingress_name" {
  type        = string
  description = "Name of the ingress, must be unique."
  default     = "traefik-dashboard"
}

variable "dashboard_ingress_labels" {
  type        = map(string)
  description = "Map of string keys and values that can be used to organize and categorize the ingress."
  default     = {
    "name" = "traefik-dashboard"
  }
}

variable "dashboard_ingress_backend_path" {
  type        = string
  description = "The path for the service entry point."
  default     = "/"
}

variable "dns_zone_name" {
  type        = string
  description = "The dns_zone_name. For sandbox this is including the identity name."
}

variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "autoscaling_group_ids" {
  type = set(string)
}

# variable "traefik_k8s_name" {}

variable "alb_certificate_arn" {
  type = string
}

variable "nodes_sg_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type = string
}

variable "access_logs_bucket" {
  type = string
}

variable "access_logs_enabled" {
  type    = bool
  default = true
}

# Blue variant

variable "deploy_blue_variant" {
  type        = bool
  description = "Whether to deploy a blue variant target group for the listener."
  default     = true
}

variable "blue_variant_target_http_port" {
  type = number
}

variable "blue_variant_target_admin_port" {
  type = number
}

variable "blue_variant_health_check_path" {
  type = string
}

variable "blue_variant_weight" {
  type = number
}

# Green variant

variable "deploy_green_variant" {
  type        = bool
  description = "Whether to deploy a green variant target group for the listener."
  default     = false
}

variable "green_variant_target_http_port" {
  type = number
}

variable "green_variant_target_admin_port" {
  type = number
}

variable "green_variant_health_check_path" {
  type = string
}

variable "green_variant_weight" {
  type = number
}

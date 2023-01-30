variable "deploy" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "cluster_name" {
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
}

variable "autoscaling_group_ids" {
  type = list(string)
}

# variable "traefik_k8s_name" {}

variable "alb_certificate_arn" {
}

variable "nodes_sg_id" {
}

variable "azure_tenant_id" {
}

variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "target_http_port" {
  type = number
}

variable "target_admin_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "access_logs_bucket" {
  type = string
}

variable "access_logs_enabled" {
  type    = bool
  default = true
}

variable "deploy_variant" {
  type        = bool
  description = "Whether to deploy a variant target group for the listener."
  default     = false
}

variable "variant_target_http_port" {
  type = number
}

variable "variant_target_admin_port" {
  type = number
}

variable "variant_health_check_path" {
  type = string
}

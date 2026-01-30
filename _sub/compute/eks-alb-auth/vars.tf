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

variable "blue_variant_target_http_port" {
  type        = number
  description = "NodePort value for the 'web' entrypoint in Traefik"
}

variable "blue_variant_target_admin_port" {
  type        = number
  description = "NodePort value for the 'traefik' entrypoint in Traefik"
}

variable "blue_variant_health_check_path" {
  type        = string
  description = "The AWS ALB will call this path on Traefik to evaluate node liveness"
}

variable "blue_variant_weight" {
  type        = number
  description = "The weight of the requests towards the blue variant of Traefik"
}

# Green variant

variable "green_variant_target_http_port" {
  type        = number
  description = "NodePort value for the 'web' entrypoint in Traefik"
}

variable "green_variant_target_admin_port" {
  type        = number
  description = "NodePort value for the 'traefik' entrypoint in Traefik"
}

variable "green_variant_health_check_path" {
  type        = string
  description = "The AWS ALB will call this path on Traefik to evaluate node liveness"
}

variable "green_variant_weight" {
  type        = number
  description = "The weight of the requests towards the green variant of Traefik"
}

variable "enable_delete_protection" {
  type        = bool
  default     = true
  description = "Enable or disable delete protection for the ALB. Not applicable for sandbox environments."
}

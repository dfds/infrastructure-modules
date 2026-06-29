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

variable "blue_variant_weight" {
  type        = number
  description = "The weight of the requests towards the blue variant of Traefik"
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

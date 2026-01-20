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

variable "access_logs_bucket" {
  type = string
}

# Blue variant
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

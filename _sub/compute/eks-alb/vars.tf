variable "deploy" {
  type    = bool
  default = true
}

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
  type = list(string)
}

# variable "traefik_k8s_name" {}

variable "alb_certificate_arn" {
  type = string
}

variable "nodes_sg_id" {
  type = string
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

variable "deploy" {
  type    = bool
  default = true
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


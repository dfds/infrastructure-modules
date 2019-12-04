variable "deploy" {
  default = true
}

variable "cluster_name" {}

variable "subnet_ids" {
  type = "list"
}
variable "vpc_id" {}

variable "autoscaling_group_ids" {
  type = "list"
}

# variable "traefik_k8s_name" {}

variable "alb_certificate_arn" {}

variable "nodes_sg_id" {}
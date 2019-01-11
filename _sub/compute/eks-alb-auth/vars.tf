#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "cluster_name" {}

variable "subnet_ids" {
  type = "list"
}
variable "vpc_id" {}
variable "autoscaling_group_id" {}

# variable "traefik_k8s_name" {}

variable "alb_certificate_arn" {}

variable "nodes_sg_id" {}

variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}


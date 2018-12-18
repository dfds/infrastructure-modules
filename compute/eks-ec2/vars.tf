#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "aws_region" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "assume_role_arn" {
  type = "string"
}

variable "worker_instance_max_count" {
  type = "string"
}

variable "worker_instance_min_count" {
  type = "string"
}

variable "worker_instance_type" {
  type = "string"
}

variable "public_key"  {
  type = "string"
}

variable "enable_ssh" {
  type = "string"
  default = 0
}

variable "traefik_k8s_name" {}

variable "alb_certificate_arn" {}


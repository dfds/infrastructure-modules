variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
}

variable "vpc_id" {
}

# variable "nlb_certificate_arn" {}

variable "nodes_sg_id" {
}

variable "cidr_blocks" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "nlb_certificate_arn" {
}

variable "autoscaling_group_ids" {
  type = list(string)
}


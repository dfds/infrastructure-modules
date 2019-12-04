variable "deploy" {
    default = true
}
variable "cluster_name" {}

variable "vpc_id" {}

# variable "nlb_certificate_arn" {}

variable "nodes_sg_id" {}

variable "cidr_blocks" {
    type = "list"
}

variable "subnet_ids" {
    type = "list"
}

variable "nlb_certificate_arn" {
  
}

variable "autoscaling_group_ids" {
  type = "list"
}

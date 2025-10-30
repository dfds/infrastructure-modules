variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

# variable "nlb_certificate_arn" {}

variable "nodes_sg_id" {
  type = string
}

# variable "cidr_blocks" {
#   type = list(string)
# }

variable "subnet_ids" {
  type = list(string)
}

# variable "nlb_certificate_arn" {
#   type = string
# }

variable "autoscaling_group_ids" {
  type = list(string)
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
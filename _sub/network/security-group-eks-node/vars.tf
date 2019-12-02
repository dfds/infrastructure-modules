variable "vpc_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "autoscale_security_group" {
  type = "string"
}

variable "ssh_ip_whitelist" {
  type = "list"
}

variable "cluster_name" {
  type = "string"
}

variable "cluster_version" {
  type = "string"
}

variable "nodegroup_name" {
  type = "string"
}

variable "node_role_arn" {
  type = "string"
}

variable "scaling_config_min_size" {}

variable "scaling_config_max_size" {}

variable "subnet_ids" {
  type = "list"
}

variable "disk_size" {}

variable "instance_types" {
  type = "list"
}

variable "ssh_ip_whitelist" {
  type = "list"
}

variable "ec2_ssh_key" {
  type = "string"
}

variable "autoscale_security_group" {}

variable "vpc_id" {}

variable "eks_endpoint" {}
variable "eks_certificate_authority" {}

variable "cloudwatch_agent_config_bucket" {}

variable "cloudwatch_agent_config_file" {}

variable "cloudwatch_agent_enabled" {
  default = false
}

variable "worker_inotify_max_user_watches" {}

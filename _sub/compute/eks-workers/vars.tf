variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "worker_instance_type" {
}

variable "worker_instance_min_count" {
  default = 0
}

variable "worker_instance_max_count" {
  default = 0
}

variable "autoscale_security_group" {
}

variable "worker_instance_storage_size" {
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "eks_endpoint" {
}

variable "eks_certificate_authority" {
}

variable "ec2_ssh_key" {
  type = string
}

variable "cloudwatch_agent_config_bucket" {
}

variable "cloudwatch_agent_config_file" {
}

variable "cloudwatch_agent_enabled" {
  default = false
}

variable "worker_inotify_max_user_watches" {
}


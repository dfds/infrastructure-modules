variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "nodegroup_name" {
  type = string
}

# variable "node_role_arn" {
#   type = "string"
# }

variable "iam_instance_profile" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "scaling_config_min_size" {
}

variable "scaling_config_max_size" {
}

variable "subnet_ids" {
  type = list(string)
}

variable "disk_size" {
}

variable "instance_types" {
  type = list(string)
}

variable "ec2_ssh_key" {
  type = string
}

variable "autoscale_security_group" {
}

variable "eks_endpoint" {
}

variable "eks_certificate_authority" {
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

variable "kubelet_extra_args" {
  type    = string
  default = ""
}

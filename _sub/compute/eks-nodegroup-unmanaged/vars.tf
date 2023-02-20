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

variable "desired_size_per_subnet" {
  type    = number
  default = 0
}

variable "subnet_ids" {
  type = list(string)
}

variable "disk_size" {
  type = number
}

variable "instance_types" {
  type    = list(string)
  default = []
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "Pins the AMI ID of the nodes to the specified AMI, bypassing AMI updates."
}

variable "gpu_ami" {
  type        = bool
  default     = false
  description = "Deploys the latest amazon-eks-gpu-node. Note, this field is ignored if ami_id is set."
}

variable "ec2_ssh_key" {
  type = string
}

variable "eks_endpoint" {
  type = string
}

variable "container_runtime" {
  type    = string
  default = "containerd"
}

variable "eks_certificate_authority" {
  type = string
}

variable "cloudwatch_agent_config_bucket" {
  type = string
}

variable "cloudwatch_agent_config_file" {
  type = string
}

variable "cloudwatch_agent_enabled" {
  type    = bool
  default = false
}

variable "worker_inotify_max_user_watches" {
  type = number
}

variable "kubelet_extra_args" {
  type    = string
  default = ""
}

variable "is_sandbox" {
  type        = bool
  description = "Indicates a sandbox cluster, causing ASG to scale to zero every night"
  default     = false
}

variable "scale_to_zero_cron" {
  type        = string
  description = "The time when the ASG will be scaled to zero, specified in Unix cron syntax"
}

variable "vpc_cni_prefix_delegation_enabled" {
  type        = bool
  description = "Configures the maximum pods limit on the nodes assuming that the prefix delegation feature is enabled on the VPC CNI addon."
  default     = false
}

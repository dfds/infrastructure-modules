variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "nodegroup_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "desired_size_per_subnet" {
  type    = number
  default = 0
}

variable "taints" {
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = []
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {
  type = list(string)
}

variable "use_spot_instances" {
  type        = bool
  default     = false
  description = "Whether the node group should attempt to utilize spot instances."
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

variable "ec2_ssh_key" {
  type = string
}

variable "eks_endpoint" {
  type = string
}

variable "eks_certificate_authority" {
  type = string
}

variable "eks_service_cidr" {
  type        = string
  description = "The CIDR block IPv4 used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself."
}

variable "worker_inotify_max_user_watches" {
  type = number
}

variable "docker_hub_creds_ssm_path" {
  type        = string
  description = "Docker Hub credentials SSM Parameter Store path"
}

# ------------------------------------------------------
# Inactivity based scale down for sandboxes
# ------------------------------------------------------

variable "enable_scale_to_zero_after_business_hours" {
  type        = bool
  default     = true
  description = "Enables automated scale to zero of EC2 instance after business hours. Only applicable to sandboxes."
}

variable "scale_to_zero_cron" {
  type        = string
  description = "The time when the ASG will be scaled to zero, specified in Unix cron syntax"
}

variable "max_unavailable" {
  type        = number
  description = "Desired max number of unavailable worker nodes during node group update."
  default     = null
}

variable "max_unavailable_percentage" {
  type        = number
  description = "Desired max percentage of unavailable worker nodes during node group update."
  default     = null
}
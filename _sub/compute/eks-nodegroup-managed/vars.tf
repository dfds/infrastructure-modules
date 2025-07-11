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

variable "disk_type" {
  type = string

  validation {
    condition     = contains(["gp2", "gp3"], var.disk_type)
    error_message = "Allowed types for the disk are gp2 or gp3."
  }
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

variable "eks_certificate_authority" {
  type = string
}

variable "worker_inotify_max_user_watches" {
  type = number
}

variable "docker_hub_username" {
  type        = string
  description = "Docker Hub username for pulling images"
  sensitive   = true
  default     = ""
}

variable "docker_hub_password" {
  type        = string
  description = "Docker Hub password for pulling images"
  sensitive   = true
  default     = ""
}

variable "essentials_url" {
  type        = string
  description = "HTTP server that provides essentials"
  default     = ""
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

variable "vpc_cni_prefix_delegation_enabled" {
  type        = bool
  description = "Configures the maximum pods limit on the nodes assuming that the prefix delegation feature is enabled on the VPC CNI addon."
  default     = false
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

variable "max_pods" {
  type        = number
  description = "Maximum number of Pods that can run on the Kubelet"
  default     = 110
}

variable "kube_reserved_cpu" {
  type        = string
  description = "CPU reserved for kubernetes system components"
  default     = null
}

variable "kube_reserved_memory" {
  type        = string
  description = "Memory reserved for kubernetes system components"
  default     = null
}

variable "system_reserved_cpu" {
  type        = string
  description = "CPU reserved for system components"
  default     = null
}

variable "system_reserved_memory" {
  type        = string
  description = "Memory reserved for system components"
  default     = null
}

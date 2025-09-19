# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

# Optional
# --------------------------------------------------

variable "ssm_param_createdby" {
  type        = string
  description = "The value that will be used for the createdBy key when tagging any SSM parameters"
  default     = null
}


# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "eks_cluster_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC. This is used to create the VPC and subnets for the EKS cluster."
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.eks_cluster_cidr_block, 1)) && tonumber(substr(var.eks_cluster_cidr_block, -2, -1)) <= 20 && tonumber(substr(var.eks_cluster_cidr_block, -2, -1)) >= 16
    error_message = "The CIDR block must be a valid CIDR block, and at between /16 and /20 in size."
  }
}

variable "eks_ipam_enabled" {
  type        = bool
  description = "Whether to use AWS IPAM for EKS cluster CIDR allocation"
  default     = false
}

variable "eks_ipam_pool_description" {
  type        = string
  description = "The description of the IPAM pool for AWS IPAM assignment. Used to filter out the correct pool."
  default     = "platform-eks-ipam-pool"
}

variable "eks_ipam_prefix_size" {
  type        = number
  description = "The CIDR block prefix to use for IPAM assignment"
  default     = 20
  validation {
    condition     = var.eks_ipam_prefix_size >= 16 && var.eks_ipam_prefix_size <= 20
    error_message = "The CIDR block prefix must be a valid number, and have a value between 16 and 20 (inclusive)."
  }
}

variable "eks_worker_ssh_public_key" {
  type = string
}

variable "eks_worker_ssh_ip_whitelist" {
  type = list(string)
}

# Optional
# --------------------------------------------------

variable "eks_is_sandbox" {
  type        = bool
  description = "Specifies this is a sandbox cluster, which currently just scales ASG to zero every night"
  default     = false
}

variable "eks_cluster_zones" {
  type    = number
  default = 3
}

variable "eks_cluster_log_types" {
  type        = list(string)
  description = "A list of the desired control plane logging to enable: api, audit, authenticator, controllerManager, scheduler. See also https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html."
  default     = ["api", "audit", "authenticator"]
}

variable "eks_cluster_log_retention_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  default     = 90
}

variable "eks_worker_inotify_max_user_watches" {
  type    = number
  default = 131072 # default t3.large is 8192 which is too low
}

variable "eks_managed_worker_subnets" {
  type = list(object({
    availability_zone         = string,
    subnet_cidr               = string,
    prefix_reservations_cidrs = list(string),
  }))
  default = []
}

variable "eks_worker_scale_to_zero_cron" {
  type        = string
  description = "The time when the ASG will be scaled to zero, specified in Unix cron syntax"
  default     = "0 18 * * *"
}

variable "eks_addon_kubeproxy_version_override" {
  type    = string
  default = ""
}

variable "eks_addon_coredns_version_override" {
  type    = string
  default = ""
}

variable "eks_addon_vpccni_version_override" {
  type    = string
  default = ""
}

variable "eks_addon_vpccni_prefix_delegation_enabled" {
  type        = bool
  description = "Whether to enable the prefix delegation mode on the VPC CNI EKS addon."
  default     = false
}

variable "eks_addon_awsebscsidriver_version_override" {
  type    = string
  default = ""
}

variable "eks_addon_awsefscsidriver_version_override" {
  type    = string
  default = ""
}

variable "eks_addon_most_recent" {
  type        = bool
  default     = false
  description = "Should we use the latest version of an EKS add-on?"
}

variable "eks_public_s3_bucket" {
  description = "The name of the public S3 bucket, where non-sensitive Kubeconfig will be copied to"
  type        = string
  default     = ""
}

variable "eks_k8s_auth_api_version" {
  description = "The fully qualified version of the client authentication API."
  type        = string
  default     = "client.authentication.k8s.io/v1beta1"
}

# --------------------------------------------------
# EKS managed node group
# --------------------------------------------------
variable "eks_managed_nodegroups" {
  type = map(object({
    ami_id                     = optional(string, "")
    instance_types             = optional(list(string), ["t3.small"])
    use_spot_instances         = optional(bool, false)
    disk_size                  = optional(number, 128)
    disk_type                  = optional(string, "gp3")
    desired_size_per_subnet    = optional(number, 0)
    gpu_ami                    = optional(bool, false)
    availability_zones         = optional(list(string), [])
    max_unavailable            = optional(number, null)
    max_unavailable_percentage = optional(number, null)
    taints = optional(list(object({
      key    = string,
      value  = optional(string),
      effect = string
    })), [])
    labels      = optional(map(string), {})
    max_pods    = optional(number, 110)
    sys_cpu     = optional(string, null)
    sys_memory  = optional(string, null)
    kube_cpu    = optional(string, null)
    kube_memory = optional(string, null)
  }))
  default = {}
}

# --------------------------------------------------
# Blaster Configmap
# --------------------------------------------------

variable "blaster_configmap_bucket" {
  type    = string
  default = ""
}

variable "blaster_configmap_bucket_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(string)
  default     = {}
}

# --------------------------------------------------
# Cloudwatch agent setup
# --------------------------------------------------

variable "eks_worker_cloudwatch_agent_config_deploy" {
  type    = bool
  default = false
}

# --------------------------------------------------
# Cost and Usage Report integration
# --------------------------------------------------

variable "eks_worker_cur_bucket_arn" {
  type        = string
  default     = null
  description = "S3 ARN for Billing Cost and Usage Report (CUR)"
}

# ------------------------------------------------------
# Inactivity based clean up and scale down for sandboxes
# ------------------------------------------------------

variable "enable_inactivity_cleanup" {
  type        = bool
  default     = true
  description = "Enables automated clean up of EKS resources based on inactivity. Only applicable to sandboxes."
}

variable "enable_scale_to_zero_after_business_hours" {
  type        = bool
  default     = true
  description = "Enables automated scale to zero of EC2 instance after business hours. Only applicable to sandboxes."
}

# --------------------------------------------------
# GPU workloads
# --------------------------------------------------

variable "secure_eks_version_endpoint" {
  type        = bool
  default     = true
  description = "Whether to secure the EKS version endpoint"
}

variable "efs_automated_backup_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable automated backups for the EFS file system"
}

# --------------------------------------------------
# Docker Hub credentials
# --------------------------------------------------

variable "docker_hub_username" {
  type        = string
  description = "Docker Hub username for pulling images"
  sensitive   = true
}

variable "docker_hub_password" {
  type        = string
  description = "Docker Hub password for pulling images"
  sensitive   = true
}

variable "essentials_url" {
  type        = string
  description = "HTTP server that provides essentials"
  default     = "https://dfds-k8s-cluster-essentials.s3.eu-central-1.amazonaws.com"
}

# --------------------------------------------------
# NAT Gateway
# --------------------------------------------------

variable "enable_worker_nat_gateway" {
  type        = bool
  default     = false
  description = <<EOF
  Whether to enable dormant NAT Gateway for worker nodes.
  To be used in conjunction with use_worker_nat_gateway later.
  This is to ensure the NAT Gateway available before it is used, and hence reduce downtime.
EOF
}

variable "use_worker_nat_gateway" {
  type        = bool
  default     = false
  description = "Whether to use NAT Gateway for worker nodes"
}

variable "migrate_vpc_peering_routes" {
  description = "If true, migrate the peering connection to the new route table"
  type        = bool
  default     = false
}

variable "eks_addon_awsebscsidriver_kms_arn" {
  type        = string
  description = "ARN of the KMS key to use for the EBS Volumes"
  default     = ""
}

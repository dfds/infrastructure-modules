# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
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

variable "eks_worker_subnets" {
  type    = list(string)
  default = []
}

variable "eks_managed_worker_subnets" {
  type = list(object({
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

variable "eks_public_s3_bucket" {
  description = "The name of the public S3 bucket, where non-sensitive Kubeconfig will be copied to"
  type        = string
  default     = ""
}

variable "eks_k8s_auth_api_version" {
  description = "The fully qualified version of the client authentication API."
  type        = string
  default     = "client.authentication.k8s.io/v1alpha1"
}


# --------------------------------------------------
# EKS Nodegroup 1
# --------------------------------------------------

variable "eks_nodegroup1_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "eks_nodegroup1_container_runtime" {
  type    = string
  default = "containerd"
}

variable "eks_nodegroup1_disk_size" {
  type    = number
  default = 128
}

variable "eks_nodegroup1_ami_id" {
  type        = string
  default     = ""
  description = "Pins the AMI ID of the nodes to the specified AMI, bypassing AMI updates."
}

variable "eks_nodegroup1_gpu_ami" {
  type        = bool
  default     = false
  description = "Deploys the latest amazon-eks-gpu-node. Note, this field is ignored if eks_nodegroup1_ami_id is set."
}

variable "eks_nodegroup1_kubelet_extra_args" {
  type    = string
  default = ""
}

variable "eks_nodegroup1_desired_size_per_subnet" {
  type    = number
  default = 0
}


# --------------------------------------------------
# EKS Nodegroup 2
# --------------------------------------------------

variable "eks_nodegroup2_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "eks_nodegroup2_container_runtime" {
  type    = string
  default = "containerd"
}

variable "eks_nodegroup2_disk_size" {
  type    = number
  default = 128
}

variable "eks_nodegroup2_ami_id" {
  type        = string
  default     = ""
  description = "Pins the AMI ID of the nodes to the specified AMI, bypassing AMI updates."
}

variable "eks_nodegroup2_gpu_ami" {
  type        = bool
  default     = false
  description = "Deploys the latest amazon-eks-gpu-node. Note, this field is ignored if eks_nodegroup2_ami_id is set."
}

variable "eks_nodegroup2_kubelet_extra_args" {
  type    = string
  default = ""
}

variable "eks_nodegroup2_desired_size_per_subnet" {
  type    = number
  default = 0
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

variable "eks_worker_cloudwatch_agent_config_file" {
  type    = string
  default = "aws-cloudwatch-agent-conf.json"
}

# --------------------------------------------------
# Cost and Usage Report integration
# --------------------------------------------------

variable "eks_worker_cur_bucket_arn" {
  type        = string
  default     = null
  description = "S3 ARN for Billing Cost and Usage Report (CUR)"
}

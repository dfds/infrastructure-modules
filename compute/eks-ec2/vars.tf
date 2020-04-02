# --------------------------------------------------
# Terraform
# --------------------------------------------------

variable "terraform_state_s3_bucket" {
  type = string
}

# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "aws_workload_account_id" {
}


# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "workload_dns_zone_name" {
  type    = string
  default = ""
}

# variable "azure_tenant_id" {
#   type    = string
#   default = ""
# }

variable "terraform_state_region" {
  type    = string
  default = ""
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

variable "eks_cluster_zones" {
  default = 2 # Set to the number of AZs Hellman currently uses, to reduce risk of destroying/recreating cluster, until a better solution is in place
}

variable "eks_cluster_log_types" {
  type = list(string)
  description = "A list of the desired control plane logging to enable: api, audit, authenticator, controllerManager, scheduler. See also https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html."
  default = ["api", "audit", "authenticator"]
}

variable "eks_cluster_log_retention_days" {
  type = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  default = 90 
}

variable "eks_worker_instance_type" {
  type = string
}

variable "eks_worker_instance_min_count" {
  type    = string
  default = 0
}

variable "eks_worker_instance_max_count" {
  type    = string
  default = 0
}

variable "eks_worker_instance_storage_size" {
  default = 20
}

variable "eks_worker_ssh_public_key" {
  type = string
}

variable "eks_worker_inotify_max_user_watches" {
  default = 131072 # default t3.large is 8192 which is too low
}

variable "eks_worker_subnets" {
  type    = list(string)
  default = []
}

variable "eks_worker_ssh_ip_whitelist" {
  type = list(string)
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

variable "eks_public_s3_bucket" {
  description = "The name of the public S3 bucket, where non-sensitive Kubeconfig will be copied to."
  type        = string
  default     = ""
}


# --------------------------------------------------
# EKS Nodegroup 1
# --------------------------------------------------

variable "eks_nodegroup1_instance_types" {
  type    = list(string)
  default = []
}

variable "eks_nodegroup1_gpu_ami" {
  type    = bool
  default = false
}

variable "eks_nodegroup1_kubelet_extra_args" {
  type    = string
  default = ""
}

variable "eks_nodegroup1_instance_min_count" {
  default = 0
}

variable "eks_nodegroup1_instance_max_count" {
  default = 0
}

# --------------------------------------------------
# EKS Nodegroup 2
# --------------------------------------------------

variable "eks_nodegroup2_instance_types" {
  type    = list(string)
  default = []
}

variable "eks_nodegroup2_gpu_ami" {
  type    = bool
  default = false
}

variable "eks_nodegroup2_kubelet_extra_args" {
  type    = string
  default = ""
}

variable "eks_nodegroup2_instance_min_count" {
  default = 0
}

variable "eks_nodegroup2_instance_max_count" {
  default = 0
}

# --------------------------------------------------
# Blaster Configmap
# --------------------------------------------------

variable "blaster_configmap_bucket" {
  type    = string
  default = ""
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


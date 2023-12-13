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
    disk_type                  = optional(string, "gp2")
    desired_size_per_subnet    = optional(number, 0)
    kubelet_extra_args         = optional(string, "")
    gpu_ami                    = optional(bool, false)
    availability_zones         = optional(list(string), [])
    max_unavailable            = optional(number, null)
    max_unavailable_percentage = optional(number, null)
    taints = optional(list(object({
      key    = string,
      value  = optional(string),
      effect = string
    })), [])
    labels = optional(map(string), {})
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

# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

variable "disable_inactivity_cleanup" {
  type        = bool
  default     = false
  description = "Disables automated clean up of EKS resources based on inactivity. Only applicable to sandboxes."
}

# --------------------------------------------------
# GPU workloads
# --------------------------------------------------

variable "deploy_nvidia_device_plugin" {
  type        = bool
  default     = false
  description = "Whether to deploy NVIDIA device plugin. This needs to be set to `true` when GPU based workloads needs to be enabled."
}

variable "nvidia_chart_version" {
  type        = string
  description = "Nvidia device plugin helm chart version"
  default     = null
}

variable "nvidia_namespace" {
  type        = string
  description = "Nvidia device plugin namespace"
  default     = null
}

variable "create_nvidia_namespace" {
  type        = bool
  description = "Whether to create a namespace with helm"
  default     = false
}

variable "nvidia_device_plugin_tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  description = "A list of tolerations to apply to the nvidia device plugin deployment"
  default     = []
}

variable "nvidia_device_plugin_affinity" {
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  description = "A list of affinities to apply to the nvidia device plugin deployment"
  default     = []
}

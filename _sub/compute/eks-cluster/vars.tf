variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_zones" {
  type = number
}

variable "cluster_subnets" {
  type = number
}

variable "worker_subnet_ids" {
  type = list(string)
}

variable "log_types" {
  type        = list(string)
  description = "A list of the desired control plane logging to enable: api, audit, authenticator, controllerManager, scheduler. See also https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html."
  default     = ["api", "audit", "authenticator", "scheduler", "controllerManager"]
}

variable "log_retention_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  default     = 90
}

variable "sleep_after" {
  type        = number
  default     = 120
  description = "The AWS API will return OK before the Kubernetes cluster is actually available. Wait an arbitrary amount of time for cluster to become ready. Workaround for https://github.com/aws/containers-roadmap/issues/654"
}

variable "assume_role_arn" {
  type = string
}

variable "migrate_to_eks_automode" {
  type        = bool
  description = "Has/is this cluster been/being migrated to EKS Auto Mode?"
  default     = false
}

variable "additional_security_groups" {
  type        = list(string)
  description = "A list of additional security groups to attach to the EKS cluster VPC for Auto Mode."
  default     = []
}
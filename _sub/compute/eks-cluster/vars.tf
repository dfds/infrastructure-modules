variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_zones" {
  type = number
}


variable "cluster_reserved_cidr" {
  type        = string
  description = "The CIDR block reserved for the control plane subnets. This is used to create the subnets for the EKS cluster control plane."
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

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC. This is used to create the VPC and subnets for the EKS cluster."
}

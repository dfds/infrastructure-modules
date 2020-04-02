variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_zones" {
}

variable "log_types" {
  type = list(string)
  description = "A list of the desired control plane logging to enable: api, audit, authenticator, controllerManager, scheduler. See also https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html."
  default = []
}

variable "log_retention_days" {
  type = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  default = 90
}

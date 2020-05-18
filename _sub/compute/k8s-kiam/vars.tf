variable "deploy" {
  type    = bool
  default = true
}

variable "aws_workload_account_id" {
}

variable "cluster_name" {
  type = string  
}

variable "worker_role_id" {
}

variable "priority_class" {
  description = "Name of the Kubernetes priority class pods should use"
  type = string  
}

variable "deploy" {
  default = true
}

variable "aws_workload_account_id" {}

variable "cluster_name" {}

variable "worker_role_id" {}

variable "kubeconfig_path" {
  type = "string"
}

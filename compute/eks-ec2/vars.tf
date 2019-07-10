# --------------------------------------------------
# Terraform
# --------------------------------------------------

variable "terraform_state_s3_bucket" {
  type = "string"
}

# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "aws_workload_account_id" {}

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = "string"
}

variable "eks_worker_instance_type" {
  type = "string"
}

variable "eks_worker_instance_min_count" {
  type = "string"
}

variable "eks_worker_instance_max_count" {
  type = "string"
}

variable "eks_worker_instance_storage_size" {
  default = 20
}

variable "eks_worker_ssh_public_key" {
  type = "string"
}

variable "eks_worker_ssh_enable" {
  default = false
}


# --------------------------------------------------
# Blaster Configmap
# --------------------------------------------------

variable "blaster_configmap_deploy" {
  default = false
}

variable "blaster_configmap_bucket" {}


# --------------------------------------------------
# Cloudwatch agent setup
# --------------------------------------------------

variable "eks_worker_cloudwatch_agent_config_deploy" {
  default = false
}

variable "eks_worker_cloudwatch_agent_config_file" {
  type = "string"
}

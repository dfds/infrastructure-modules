#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "aws_region" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "assume_role_arn" {
  type = "string"
}

variable "worker_instance_max_count" {
  type = "string"
}

variable "worker_instance_min_count" {
  type = "string"
}

variable "worker_instance_type" {
  type = "string"
}

variable "worker_instance_storage_size" {
  default = 20
}

variable "public_key"  {
  type = "string"
}

variable "enable_ssh" {
  type = "string"
  default = 0
}

variable "dns_zone_name" {}

variable "table_name" {}

variable "workload_account_id" {}


#OIDC ALB_auth
variable "azure_tenant_id" {}
# variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "deploy" {
  default = true
}

variable "bucket_name" {
}

variable "namespace" {
}

variable "cluster_name" {
}

variable "registry_endpoint" {
}

variable "registry_endpoint_external_url" {
}

variable "notary_endpoint" {
}

variable "s3_region" {
}

variable "s3_region_endpoint" {
}

variable "db_server_host" {
}

variable "db_server_username" {
}

variable "db_server_password" {
}

variable "db_server_port" {
}

variable "portal_admin_password" {
}

variable "db_server_default_db_name" {
}

variable "aws_workload_account_id" {
  description = "Workload account ID where Kiam is running"
}

variable "kiam_server_role_id" {
  description = "The ID of the AWS Role assigned to Kiam server."
}


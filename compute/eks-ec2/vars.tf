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

variable "terraform_state_s3_bucket" {}

variable "blaster_configmap_bucket" {}

variable "container_registry_bucket_name" {
  type = "string"
}

variable "harbor_db_instance_size" {
  type = "string"
}

variable "harbor_postgresdb_engine_version" {
  type = "string"
}

variable "harbor_db_storage_size" {
  type = "string"
}

variable "harbor_db_server_identifier" {
  type = "string"
}

variable "harbor_db_server_username" {
  type = "string"
}

variable "harbor_db_server_password" {
  type = "string"
}

variable "harbor_db_server_port" {}

variable "k8s_registry_namespace" {
  type = "string"
}

variable "cr_s3bucket_user_aws_access_key_id" {
   type = "string"
}

variable "cr_s3bucket_user_aws_secret_access_key" {
   type = "string"
}
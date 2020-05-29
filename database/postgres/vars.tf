variable "aws_region" {
  type = string
}

variable "application" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "db_storage_type" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_engine_major_version" {
  type = string
}

variable "db_engine_minor_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_master_username" {
  type = string
}

variable "db_master_password" {
  type = string
}

variable "db_port" {
  description = "The port to use for the database"
  default     = 5432
}

variable "db_deletion_protection" {
  default = true
}

variable "skip_final_snapshot" {
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}


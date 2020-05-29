variable "aws_region" {
  type = string
}

variable "application" {
  type = string
}

variable "environment" {
  type    = string
}

variable "db_storage_type" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
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
  type = number
}

variable "db_deletion_protection" {
  type = bool
  default = true
}

variable "skip_final_snapshot" {
  type = bool
}


variable "aws_region" {
  type    = string
}

variable "application" {
  type    = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "db_storage_type" {
  type    = string
  default = "gp2"
}

variable "db_instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_engine_major_version" {
  type    = string
  default = "10"
}

variable "db_engine_minor_version" {
  type    = string
  default = "9"
}

variable "db_name" {
  type    = string
}

variable "db_master_username" {
  type    = string
}

variable "db_master_password" {
  type    = string
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_deletion_protection" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}


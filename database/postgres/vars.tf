variable "aws_region" {
  type = string
}

variable "application" {
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

variable "environment" {
  type    = string
  default = "prod"
}

variable "db_port" {
  default     = 5432
  description = "The port to use for the database"
}

variable "skip_final_snapshot" {
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}

variable "create_before_destroy" {
  type        = bool
  description = "Define if the parameter group should be created before being destroyed"
  default     = true
}

variable "engine_version" {
  type        = string
  description = "RDS engine version"
  default     = 10
}

variable "db_instance_class" {
  type        = string
  description = "RDS database instance class"
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "The amount of space, in GB, to allocate for the database"
  default     = 20
}

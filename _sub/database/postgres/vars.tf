variable "environment" {
  default     = "prod"
  description = "the environment"
}

variable "application" {
  description = "the application"
}

variable "db_name" {
  description = "The name of the database"
}

variable "db_master_username" {
  description = "The username for the master user of the database"
}

variable "db_master_password" {
  description = "The password for the master user of the database"
}

variable "db_port" {
  default     = 5432
  description = "The port to use for the database"
}

variable "db_storage_type" {
  description = "The type of storage to use for the DB. Must be one of: standard, gp2, or io."
  default     = "gp2"
}

variable "db_instance_class" {
  description = "The instance class of the DB (e.g. db.t2.micro)"
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "The amount of space, in GB, to allocate for the database"
  default     = 20
}

variable "skip_final_snapshot" {
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}

variable "engine_version" {
  type        = string
  description = "RDS engine version (expects major version)"
  default     = null
}

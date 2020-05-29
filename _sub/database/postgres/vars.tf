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
  description = "The port to use for the database"
  default     = 5432
}

variable "db_storage_type" {
  description = "The type of storage to use for the DB. Must be one of: standard, gp2, or io."
  default     = "gp2"
}

variable "db_instance_class" {
  description = "The instance class of the DB (e.g. db.t2.micro)"
  default     = "db.t2.micro"
}

variable "db_engine_major_version" {
  description = "The database engine major version"
  default     = "10"
}

variable "db_engine_minor_version" {
  description = "The database engine minor version"
  default     = "9"
}

variable "db_allocated_storage" {
  description = "The amount of space, in GB, to allocate for the database"
  default     = 20
}

variable "db_auto_minor_version_upgrade" {
  description = "Should the db auto update minor versions during maintenance windows"
  default     = false
}

variable "skip_final_snapshot" {
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}
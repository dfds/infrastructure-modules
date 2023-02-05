variable "environment" {
  type        = string
  default     = "prod"
  description = "the environment"
}

variable "application" {
  type        = string
  description = "the application"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
}

variable "db_master_username" {
  type        = string
  description = "The username for the master user of the database"
}

variable "db_master_password" {
  type        = string
  description = "The password for the master user of the database"
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "The port to use for the database"
}

variable "db_storage_type" {
  type        = string
  description = "The type of storage to use for the DB. Must be one of: standard, gp2, or io."
  default     = "gp2"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class of the DB (e.g. db.t2.micro)"
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "The amount of space, in GB, to allocate for the database"
  default     = 20
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}

variable "engine_version" {
  type        = string
  description = "RDS engine version (expects major version)"
  default     = null
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Define if major version upgrades to the Postgres engine are allowed"
  default     = true
}

variable "ssl_mode" {
  type        = string
  description = "Specifies the kind of SSL Mode to use"
  default     = "Require"
  validation {
    condition     = contains(["Require", "VerifyFull", "VerifyCA"], var.ssl_mode)
    error_message = "Invalid value for SSL mode. Valid values: Require, VerifyFull, VerifyCA."
  }
}

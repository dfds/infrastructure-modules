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
  description = "The instance class of the DB (e.g. db.t3.micro)"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "The amount of space, in GB, to allocate for the database"
  default     = 20
}

variable "db_max_allocated_storage" {
  type        = number
  description = "The space limit, in GB, which autoscaling can scale up to"
  default     = 0 # Autoscaling disabled
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}

variable "engine_version" {
  type        = string
  description = "RDS engine version (expects major version)"
  default     = 14
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

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Protect database against deletion?"
}


variable "db_backup_retention_period" {
  type        = number
  description = "The days to retain database backups for"
  default     = 10
}

variable "rds_instance_tags" {
  type        = map(string)
  description = "A map of tags to apply only to the to RDS instance"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "publicly_accessible" {
  type        = bool
  default     = true
  description = "Should the database be public accessible?"
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate to use for the RDS instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = true
}

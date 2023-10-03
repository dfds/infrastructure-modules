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
  type        = number
  default     = 5432
  description = "The port to use for the database"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
}

variable "engine_version" {
  type        = string
  description = "RDS engine version"
  default     = 14
}

variable "db_instance_class" {
  type        = string
  description = "RDS database instance class"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "The amount of space, in GB, to allocate for the database"
}

variable "db_max_allocated_storage" {
  type        = number
  description = "The space limit, in GB, which autoscaling can scale up to"
  default     = 0 # Autoscaling disabled
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

variable "db_publicly_accessible" {
  type        = bool
  default     = true
  description = "Should the database be public accessible?"
}

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

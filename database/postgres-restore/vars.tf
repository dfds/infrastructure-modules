variable "aws_region" {
  type = string
}

variable "db_snapshot" {
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
  default     = 1433
  description = "The port to use for the database"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
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

variable "db_publicly_accessible" {
  type        = bool
  default     = true
  description = "Should the database be public accessible?"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "data_tags" {
  type        = map(string)
  description = "A map of tags to apply to all the data and/or storage deployed by the module"
  default     = {}
}

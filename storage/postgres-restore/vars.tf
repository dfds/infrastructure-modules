variable "aws_region" {
    type = "string"
}

variable "db_snapshot" {
  type = "string"
}

variable "application" {
  type = "string"
}

variable "db_name" {
  type = "string"
}

variable "db_master_username" {
  type = "string"
}

variable "db_master_password" {
  type = "string"
}

variable "environment" {
    type = "string"
    default = "prod"
}

variable "db_port" {
  default     = 1433
  description = "The port to use for the database"
}


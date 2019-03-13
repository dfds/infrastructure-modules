variable "deploy" {
  default = true
}

variable "postgresdb_engine_version" {
  type = "string"
  default = "10.6"
}

variable "db_instance_size" {
  type = "string"
}

variable "db_storage_size" {}

variable "ressource_name_prefix" {
  type = "string"
  description = "String for prefixing the name of the generated resource"
}


variable "db_name" {
  type = "string"
}

variable "db_username" {  
  type = "string"
}

variable "db_password" {
  type = "string"
}

variable "allow_connections_from_security_groups" {
  description = "Specifies a list of Security Groups to allow connections from."
  type        = "list"
  default     = []
}

variable "vpc_id" {
  description = "The id of the VPC in which this DB should be deployed."
}

variable "port" {
  default = 1433
}

variable "subnet_ids" {
  type = "list"
}


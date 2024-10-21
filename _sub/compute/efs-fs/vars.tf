variable "name" {
  type = string
  description = "Name of the EFS file system"
}

variable "performance_mode" {
  type = string
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO'"
  default = "generalPurpose"
}

variable "encrypted" {
  type = bool
  description = "Whether the file system should be encrypted"
  default = true
}

variable "throughput_mode" {
  type = string
  description = "Throughput mode for the file system. Can be either 'bursting' or 'provisioned'"
  default = "elastic"
}

variable "vpc_id" {
  type = string
  description = "The VPC ID in which to create the file system"
}

variable "vpc_subnet_ids" {
  type = list(string)
  description = "The VPC subnet IDs in which to create the file system"
}
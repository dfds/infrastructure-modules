variable "filesystem_name" {
  type = string
  description = "A unique name that will be used to identify the FileSystem and it's related resources."
  default = null
}

variable "eks_worker_subnet_ids" {
  type    = list(string)
  default = null
}

variable "securitygroup_id" {
  type = string
  description = "The Security Group ID that will be assigned to the new FileSystem."
  default = ""
}

variable "performance_mode" {
  type        = string
  description = "The performance mode to be used for the new EFS Filesystem."
  default     = "generalPurpose"

  validation {
    condition = contains(["generalPurpose","maxIO"], var.performance_mode)
    error_message = "Valid values for performance_mode are generalPurpose or maxIO."
  }
}

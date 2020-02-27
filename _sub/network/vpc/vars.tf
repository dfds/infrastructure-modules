variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC"
}


variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
}

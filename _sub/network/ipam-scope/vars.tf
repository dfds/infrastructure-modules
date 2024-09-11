variable "ipam_id" {
  type        = string
  description = "The IPAM instance id"
}

variable "scope_name" {
  type        = string
  description = "The name of the IPAM scope"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

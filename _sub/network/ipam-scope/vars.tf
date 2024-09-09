variable "ipam_id" {
  type        = string
  description = "The IPAM id"
}

variable "scope_name" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

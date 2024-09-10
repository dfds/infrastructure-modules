variable "pool" {
  type = object({
    name           = string
    cidr           = string
    address_family = optional(string, "ipv4")
    locale         = optional(string, null)
  })
  description = "The pool to create in the IPAM"
}

variable "scope_id" {
  type        = string
  description = "The IPAM scope id"
}

variable "source_ipam_pool_id" {
  type    = string
  default = null
}

variable "cascade" {
  type        = bool
  description = "Whether to cascade the deletion of the IPAM pool"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

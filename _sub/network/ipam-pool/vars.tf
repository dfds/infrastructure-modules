variable "pool" {
  type = object({
    scope_id            = string
    name                = string
    cidr                = string
    address_family      = optional(string, "IPv4")
    locale              = optional(string, null)
    source_ipam_pool_id = optional(string, null)
  })
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

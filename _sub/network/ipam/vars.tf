variable "ipam_name" {
  type        = string
  description = "The name of the IPAM"
  default     = "Company"
}

variable "ipam_regions" {
  type    = list(string)
  default = ["eu-west-1", "eu-central-1"]
}

variable "ipam_tier" {
  type        = string
  description = "The tier of the IPAM"
  default     = "advanced"
  validation {
    condition     = can(regex("^(free|advanced)$", var.tier))
    error_message = "Tier must be either 'free' or 'advanced'"
  }
}

variable "cascade" {
  type        = bool
  description = "Whether to cascade the deletion of the IPAM"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

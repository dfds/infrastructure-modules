variable "ipam_name" {
  type        = string
  description = "The name of the IPAM"
  default     = "Company"
}

variable "ipam_regions" {
  type    = list(string)
  default = ["eu-west-1", "eu-central-1"]
}

variable "private_scope_name" {
  type    = string
  default = "private"
}

variable "public_scope_name" {
  type    = string
  default = "public"
}

variable "main_pool" {
  type = object({
    name = string
    cidr = string
  })
  default = {}
}

variable "platform_pool" {
  type = object({
    name = string
    cidr = string
  })
  default = {}
}

variable "capabilities_pool" {
  type = object({
    name = string
    cidr = string
  })
  default = {}
}

variable "unused_pool" {
  type = object({
    name = string
    cidr = string
  })
  default = {}
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

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "gateway_id" {
  type    = string
  default = null
}

variable "nat_gateway_id" {
  type    = string
  default = null
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "migrate_vpc_peering_routes" {
  description = "If true, migrate the peering connection to the new route table"
  type        = bool
  default     = false
}

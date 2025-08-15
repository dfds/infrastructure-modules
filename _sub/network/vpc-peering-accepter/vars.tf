variable "destination_cidr_block" {
  type        = string
  description = "The CIDR block of the route"
}

variable "capability_id" {
  type        = string
  description = "The name of the capability peered from"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "peering_connection_id" {
  type        = string
  description = "The ID of the peering connection"
}

variable "route_table_id" {
  description = "The ID of the route table"
  type        = string
  default     = ""
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}

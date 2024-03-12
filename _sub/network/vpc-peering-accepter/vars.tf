variable "destination_cidr_block" {
    description = "The CIDR block of the route"
}  

variable "capability_name" {
    description = "The name of the capability peered from"
}

variable "vpc_id" {
    description = "The ID of the VPC"
}

variable "peering_connection_id" {
    description = "The ID of the peering connection"
}

variable "route_table_id" {
    description = "The ID of the route table"
}
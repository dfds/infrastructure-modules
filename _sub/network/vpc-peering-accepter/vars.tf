variable "route_table_id" {
    description = "The ID of the route table to which the route will be added"
}

variable "destination_cidr_block" {
    description = "The CIDR block of the route"
}  

variable "gateway_id" {
    description = "The ID of the gateway to which the route will be added"
}

variable "capability_ip_range" {
    description = "The IP range of the shared VPC"
}

variable "capability_name" {
    description = "The name of the capability peered from"
}
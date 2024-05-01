variable "cidr_block_vpc" {
  description = "The CIDR block of the VPC"
}

variable "cidr_block_subnet_a" {
  description = "The CIDR block of the first subnet"
}

variable "cidr_block_subnet_b" {
  description = "The CIDR block of the second subnet"
}

variable "cidr_block_subnet_c" {
  description = "The CIDR block of the optional third subnet"
  default     = ""
}

variable "cidr_block_peer" {
  description = "The CIDR block of the peer VPC"
}

variable "peer_owner_id" {
  description = "The AWS account ID of the owner of the peer VPC"
}

variable "peer_vpc_id" {
  description = "The ID of the peer VPC"
}

variable "peer_region" {
  description = "The region of the peer VPC"
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch"
  type        = bool
  default     = false
}

variable "deploy_vpc_peering_endpoints" {
  description = "Deploy required VPC endpoints for VPC peering SSM connections"
  type        = bool
  default     = true
}
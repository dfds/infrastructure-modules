variable "configuration_name" {
  description = "The unique name of the configuration"
  type        = string
}

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

variable "ipam_pool" {
  type        = string
  description = "The ID of the IPAM pool when using AWS IPAM assignment."
}

variable "ipam_cidr_enable" {
  description = "Use IPAM for VPC peering connections"
  type        = bool
  default     = false
}

variable "ipam_cidr_prefix" {
  description = "The CIDR block to use for IPAM assignment"
  type        = string
  default     = ""
}

variable "ipam_subnet_bits" {
  description = "The number of bits to use for subnet calculations"
  type        = list(number)
  default     = [1, 1]
}

output "vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.capability.id
}

output "vpc_cidr_block" {
  description = "The VPC CIDR block"
  value       = aws_vpc.peering.cidr_block
}

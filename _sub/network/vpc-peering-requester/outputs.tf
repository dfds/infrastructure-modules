output "vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection towards the production account"
  value       = aws_vpc_peering_connection.capability.id
}

output "standby_vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection towards the standby account"
  value       = aws_vpc_peering_connection.capability_standby.id
}

output "vpc_cidr_block" {
  description = "The VPC CIDR block"
  value       = aws_vpc.peering.cidr_block
}

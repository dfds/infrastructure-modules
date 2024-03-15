output "vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.capability.id
}

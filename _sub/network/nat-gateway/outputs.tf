output "gateway_id" {
  value = aws_nat_gateway.ng.id
}

output "public_ip" {
  value = aws_nat_gateway.ng.public_ip
}

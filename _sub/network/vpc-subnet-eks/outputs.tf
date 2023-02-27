output "subnet_ids" {
  value = aws_subnet.subnet[*].id
}

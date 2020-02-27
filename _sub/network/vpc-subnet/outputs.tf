output "ids" {
  value = aws_subnet.subnet.*.id
}

output "public_ip" {
  value = aws_eip.ip.public_ip
}

output "public_dns" {
  value = aws_eip.ip.public_dns
}

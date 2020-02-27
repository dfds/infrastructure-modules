output "id" {
  value = aws_directory_service_directory.ad.id
}

output "dns_ip_addresses" {
  value = aws_directory_service_directory.ad.dns_ip_addresses
}

output "admin_username" {
  value = "admin@${var.name}"
}

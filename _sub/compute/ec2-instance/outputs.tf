output "id" {
  value = aws_instance.instance.id
}


output "public_ip" {
  value = aws_instance.instance.public_ip
}

output "public_dns" {
  value = aws_instance.instance.public_dns
}

output "password_data" {
  value     = aws_instance.instance.password_data
  sensitive = true
}

output "password" {
  value     = length(var.private_key_path) > 0 ? rsadecrypt(aws_instance.instance.password_data, file(var.private_key_path)) : "Specify the ec2_private_key_path variable to decrypt password"
  sensitive = true
}

output "ec2_public_dns" {
  value = module.ec2_instance.public_dns
}

output "ec2_password_data" {
  value = module.ec2_instance.password_data
}

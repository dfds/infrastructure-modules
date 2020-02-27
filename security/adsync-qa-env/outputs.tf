output "admin_username" {
  value = module.activedirectory.admin_username
}

output "ec2_dns_alias" {
  value = "${element(module.ec2_dns_record.record_name, 0)}.${data.aws_route53_zone.workload.name}"
}

output "ec2_public_dns" {
  value = module.ec2_instance.public_dns
}

output "ec2_password_data" {
  value = module.ec2_instance.password_data
}

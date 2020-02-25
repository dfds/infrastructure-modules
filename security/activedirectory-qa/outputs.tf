output "subnet_ids" {
  value = module.subnets.ids
}

output "ec2_public_dns" {
  value = module.ec2_instance.public_dns
}

output "ec2_password" {
  value = module.ec2_instance.password
}

# output "main_route_table_id" {
#   value = module.vpc.main_route_table_id
# }

# output "default_route_table_id" {
#   value = module.vpc.default_route_table_id
# }

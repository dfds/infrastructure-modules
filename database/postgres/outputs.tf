output "host" {
  value = module.postgres.host
}

output "connection_string" {
  value = module.postgres.connection_string
}

output "port" {
  value = module.postgres.port
}

output "name" {
  value = module.postgres.name
}

output "username" {
  value = module.postgres.username
}

output "password" {
  value     = var.db_master_password
  sensitive = true
}

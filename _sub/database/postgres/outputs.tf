output "host" {
  value = replace(
    aws_db_instance.postgres.endpoint,
    format(":%s", aws_db_instance.postgres.port),
    "",
  )
}

output "connection_string" {
  value = "User ID=${var.db_master_username};Password=${var.db_master_password};Host=${replace(
    aws_db_instance.postgres.endpoint,
    format(":%s", var.db_port),
    "",
  )};Port=${var.db_port};Database=${var.db_name};SSL Mode=${var.ssl_mode}"
}

output "port" {
  value = aws_db_instance.postgres.port
}

output "name" {
  value = aws_db_instance.postgres.db_name
}

output "username" {
  value = aws_db_instance.postgres.username
}

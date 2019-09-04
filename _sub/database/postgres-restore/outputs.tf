output "pghost" {
  value = "${replace(aws_db_instance.postgres.endpoint, format(":%s", var.db_port), "")}"
}

output "pgconnection_string" {
  value = "User ID=${var.db_master_username};Password=${var.db_master_password};Host=${replace(aws_db_instance.postgres.endpoint, format(":%s", var.db_port), "")};Port=${var.db_port};Database=${var.db_name};SSL Mode=Require"
}


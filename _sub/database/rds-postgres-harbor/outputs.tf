output "db_address" {
  value = "${element(concat(aws_db_instance.instance.*.address, list("")), 0)}"
}

output "db_port" {
  value = "${element(concat(aws_db_instance.instance.*.port, list("")), 0)}"
}

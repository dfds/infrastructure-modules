output "db_address" {
  value = "${element(concat(aws_db_instance.instance.*.id, list("")), 0)}"
}

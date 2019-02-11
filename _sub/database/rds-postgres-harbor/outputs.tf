output "harbor_db_address" {
  value = "${aws_db_instance.harbor-db.address}"
}

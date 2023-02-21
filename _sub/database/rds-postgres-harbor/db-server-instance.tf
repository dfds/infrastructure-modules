#tfsec:ignore:aws-rds-backup-retention-specified tfsec:ignore:aws-rds-encrypt-instance-storage-data tfsec:ignore:AVD-AWS-0176 tfsec:ignore:AVD-AWS-0177 tfsec:ignore:aws-rds-specify-backup-retention tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_db_instance" "instance" {
  count             = var.deploy ? 1 : 0
  allocated_storage = var.db_storage_size
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = var.postgresdb_engine_version
  instance_class    = var.db_instance_size
  identifier_prefix = var.ressource_name_prefix
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  port              = var.port

  vpc_security_group_ids      = [aws_security_group.db[0].id]
  db_subnet_group_name        = aws_db_subnet_group.harbor-db-sg[0].id
  multi_az                    = true
  allow_major_version_upgrade = false
  deletion_protection         = false #tfsec:ignore:AVD-AWS-0177
  skip_final_snapshot         = true
}


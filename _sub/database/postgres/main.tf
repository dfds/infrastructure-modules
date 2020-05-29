resource "aws_security_group" "pgsg" {
  name_prefix = "${var.application}-postgres10-sg-${var.environment}"
  description = "Allow all inbound traffic on port ${var.db_port}"

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    environment = var.environment
  }

}

#Enable SSL on the database by default
resource "aws_db_parameter_group" "dbparams" {
  name        = "${var.application}-postgres${var.db_engine_major_version}-force-ssl-${var.environment}"
  description = "Force SSL encryption for postgres${var.db_engine_major_version}"
  family      = "postgres${var.db_engine_major_version}"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = {
    environment = var.environment
  }
}

#Restore the postgres database with the pre-configured settings
resource "aws_db_instance" "postgres" {
  engine                  = "postgres"
  publicly_accessible     = "true"
  backup_retention_period = 10
  apply_immediately       = true
  identifier              = "${var.application}-postgres-${var.environment}"
  parameter_group_name    = aws_db_parameter_group.dbparams.name
  vpc_security_group_ids  = [aws_security_group.pgsg.id]

  # deletion_protection
  final_snapshot_identifier = "${var.application}-postgres-final-${var.environment}"

  # configurable
  storage_type                = var.db_storage_type
  instance_class              = var.db_instance_class
  allocated_storage           = var.db_allocated_storage
  engine_version              = "${var.db_engine_major_version}.${var.db_engine_minor_version}"
  port                        = var.db_port
  name                        = var.db_name
  username                    = var.db_master_username
  password                    = var.db_master_password
  auto_minor_version_upgrade  = var.db_auto_minor_version_upgrade
  deletion_protection         = var.db_deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot

  timeouts {
    create = "2h"
  }

  tags = {
    environment = var.environment
  }

  #Do not re-provision database upon snapshot changes
  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}


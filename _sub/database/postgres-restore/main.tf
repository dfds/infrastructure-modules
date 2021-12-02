#tfsec:ignore:no-public-ingress-sgr tfsec:ignore:aws-vpc-no-public-ingress-sg
resource "aws_security_group" "pgsg" {
  name        = "${var.application}-postgres10-sg-${var.environment}"
  description = "Allow all inbound traffic on port ${var.db_port}"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    environment = var.environment
  }
}

#Enable SSL on the database by default
resource "aws_db_parameter_group" "dbparams" {
  name        = "${var.application}-postgres10-force-ssl-${var.environment}"
  description = "Force SSL encryption for postgres10"
  family      = "postgres10"

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
  engine_version          = "10.9"
  publicly_accessible     = "true" #tfsec:ignore:aws-rds-no-public-db-access
  backup_retention_period = 10
  apply_immediately       = true
  identifier              = "${var.application}-postgres-${var.environment}"
  snapshot_identifier     = data.aws_db_snapshot.db_snapshot.id
  parameter_group_name    = aws_db_parameter_group.dbparams.name
  vpc_security_group_ids  = [aws_security_group.pgsg.id]

  # deletion_protection
  //final_snapshot_identifier = "${var.application}-postgres-final-${var.environment}"
  final_snapshot_identifier = "${var.db_snapshot}-final-${var.environment}"

  # configurable
  storage_type        = var.db_storage_type
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  port                = var.db_port
  name                = var.db_name
  username            = var.db_master_username
  password            = var.db_master_password
  skip_final_snapshot = var.skip_final_snapshot

  timeouts {
    create = "2h"
  }

  tags = {
    environment   = var.environment
    restored_from = var.db_snapshot
  }

  #Do not re-provision database upon snapshot changes
  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}


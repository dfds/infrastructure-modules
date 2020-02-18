# ------------------------------------------------------------------------------
# CREATE THE SUBNET GROUP THAT SPECIFIES IN WHICH SUBNETS TO DEPLOY THE DB INSTANCES
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "harbor-db-sg" {
  count       = var.deploy ? 1 : 0
  name_prefix = var.ressource_name_prefix
  description = "Database subnet group for harbor"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "Harbor-rds subnet group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN CONNECT TO THE DB
# ------------------------------------------------------------------------------
resource "aws_security_group" "db" {
  count       = var.deploy ? 1 : 0
  name_prefix = var.ressource_name_prefix
  description = "Security group for Harbor Postgres Db"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "Harbor-db"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_connections_from_security_group" {
  count                    = var.deploy && length(var.allow_connections_from_security_groups) >= 0 ? length(var.allow_connections_from_security_groups) : 0
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allow_connections_from_security_groups, count.index)

  security_group_id = element(concat(aws_security_group.db.*.id, [""]), 0)

  lifecycle {
    create_before_destroy = true
  }
}


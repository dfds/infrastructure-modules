# ------------------------------------------------------------------------------
# CREATE THE SUBNET GROUP THAT SPECIFIES IN WHICH SUBNETS TO DEPLOY THE DB INSTANCES
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "harbor-db-sg" {
  count       = "${var.deploy}"
  name_prefix = "harbor-rds"                           # "${var.name_prefix}"
  description = "Database subnet group for harbor-rds"
  subnet_ids  = ["${var.subnet_ids}"]

  tags = {
    Name = "Harbor-rds subnet group"
  }
}

# ------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN CONNECT TO THE DB
# ------------------------------------------------------------------------------
resource "aws_security_group" "db" {
  count       = "${var.deploy}"
  name        = "harbor-postgres-db"
  description = "Security group for Harbor Postgres Db"
  vpc_id      = "${var.vpc_id}"

  #   tags        = "${var.custom_tags}"
  tags = "${
    map(
     "Name", "Harbor-db"
    )
  }"
}

resource "aws_security_group_rule" "allow_connections_from_security_group" {
  count                    = "${length(var.allow_connections_from_security_groups)}"
  type                     = "ingress"
  from_port                = "${var.port}"
  to_port                  = "${var.port}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.allow_connections_from_security_groups, count.index)}"

  security_group_id = "${aws_security_group.db.id}"
}

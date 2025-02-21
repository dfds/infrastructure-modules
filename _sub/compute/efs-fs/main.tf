resource "aws_efs_file_system" "this" {
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_efs_mount_target" "this" {
  for_each = { for idx, subnet_id in flatten([for k, v in var.vpc_subnet_ids : v]) : idx => subnet_id }
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.this.id]
}

resource "aws_efs_backup_policy" "this" {
  count = var.automated_backup_enabled ? 1 : 0

  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = var.automated_backup_enabled ? "ENABLED" : "DISABLED"
  }
}

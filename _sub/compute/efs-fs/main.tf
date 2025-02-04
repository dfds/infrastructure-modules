resource "aws_efs_file_system" "this" {
  #checkov:skip=CKV_AWS_184: Ensure resource is encrypted by KMS using a customer managed Key (CMK)
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "this" {
  #checkov:skip=CKV_AWS_23: Ensure every security group and rule has a description
  vpc_id = var.vpc_id
  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  description       = "NFS rules for EFS"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_efs_mount_target" "this" {
  for_each        = { for k, v in var.vpc_subnet_ids : k => v[0] }
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

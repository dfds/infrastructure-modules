resource "aws_efs_file_system" "fs" {
  encrypted = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode = var.throughput_mode
  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "fs" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "fs" {
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  security_group_id = aws_security_group.fs.id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_efs_mount_target" "fs" {
  for_each = toset(var.vpc_subnet_ids)
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = each.value
  security_groups = [aws_security_group.fs.id]
}

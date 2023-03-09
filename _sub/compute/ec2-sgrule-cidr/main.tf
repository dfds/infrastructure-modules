# tfsec:ignore:aws-ec2-no-public-ingress-sg tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group_rule" "sgr" {
  security_group_id = var.security_group_id
  description       = var.description
  type              = var.type
  protocol          = var.protocol
  from_port         = var.from_port
  to_port           = var.to_port
  cidr_blocks       = var.cidr_blocks
  self              = var.self
}

# tfsec:ignore:aws-vpc-add-description-to-security-group tfsec:ignore:aws-ec2-add-description-to-security-group-rule tfsec:ignore:aws-vpc-no-public-egress-sg tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

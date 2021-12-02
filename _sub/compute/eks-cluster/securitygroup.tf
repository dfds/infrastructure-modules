resource "aws_security_group" "eks-cluster" {
  name_prefix = "eks-${var.cluster_name}-cluster-"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks.id

  egress {
    description = "Egress for all protocols"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  tags = {
    Name = "eks-${var.cluster_name}-cluster"
  }
}

#tfsec:ignore:aws-vpc-disallow-mixed-sgr tfsec:ignore:no-public-ingress-sgr tfsec:ignore:aws-vpc-no-public-ingress-sg tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "eks-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}


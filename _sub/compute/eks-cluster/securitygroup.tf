#trivy:ignore:AVD-AWS-0104 Security group rule allows unrestricted egress to any IP address
resource "aws_security_group" "eks-cluster" {
  #checkov:skip=CKV_AWS_382: Ensure no security groups allow egress from 0.0.0.0:0 to port -1
  name_prefix = "eks-${var.cluster_name}-cluster-"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks.id

  egress {
    description = "Egress for all protocols"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-${var.cluster_name}-cluster"
  }
}

resource "aws_security_group_rule" "eks-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}

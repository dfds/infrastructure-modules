#trivy:ignore:AVD-AWS-0104 Security group rule allows unrestricted egress to any IP address
resource "aws_security_group" "eks-node" {
  #checkov:skip=CKV_AWS_382: Ensure no security groups allow egress from 0.0.0.0:0 to port -1
  name        = "eks-${var.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    description = "Egress for all protocols"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "eks-${var.cluster_name}-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "eks-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = var.autoscale_security_group
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.autoscale_security_group
  source_security_group_id = aws_security_group.eks-node.id
  to_port                  = 443
  type                     = "ingress"
}

#Enable SSH access to nodes by tfvars set to 1
resource "aws_security_group_rule" "ssh-access-to-worker-nodes" {
  #checkov:skip=CKV_AWS_24: Ensure no security groups allow ingress from 0.0.0.0:0 to port 22
  description       = "Allow SSH access to worker nodes"
  cidr_blocks       = var.ssh_ip_whitelist
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-node.id
  to_port           = 22
  type              = "ingress"
}

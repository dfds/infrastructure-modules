resource "aws_key_pair" "eks-node" {
  key_name   = "eks-${var.cluster_name}"
  public_key = "${var.public_key}"
}
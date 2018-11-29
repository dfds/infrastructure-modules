resource "aws_iam_role" "eks" {
  name = "eks-${var.cluster_name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks.name}"
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks.name}"
}


resource "aws_iam_instance_profile" "eks" {
  name = "eks-${var.cluster_name}"
  role = "${aws_iam_role.eks.name}"
}
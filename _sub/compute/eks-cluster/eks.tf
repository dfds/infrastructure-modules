resource "aws_eks_cluster" "eks" {
  name            = "${var.cluster_name}"
  role_arn        = "${aws_iam_role.eks.arn}"
  version         = "1.11"
  
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  #enabled_cluster_log_types = ["api", "audit", "authenticator","controllerManager","scheduler"]
  
  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${aws_subnet.eks.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster",
    "aws_iam_role_policy_attachment.service",
  ]
}

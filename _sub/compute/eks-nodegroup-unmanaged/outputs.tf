output "worker_role" {
  value = "${aws_iam_role.eks.arn}"
}

output "worker_role_id" {
  value = "${aws_iam_role.eks.id}"
}

output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.eks.id}"
}

output "nodes_sg_id" {
  value = "${aws_security_group.eks-node.id}"
}

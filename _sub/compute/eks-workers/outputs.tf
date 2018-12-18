output "worker_role" {
  value = "${aws_iam_role.eks.arn}"
}

output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.eks.id}"
}
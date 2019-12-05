output "worker_role" {
  value = "${aws_iam_role.eks.arn}"
}

output "worker_role_id" {
  value = "${aws_iam_role.eks.id}"
}

output "iam_instance_profile_name" {
  value = "${aws_iam_instance_profile.eks.name}"
}

output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.eks.id}"
}
output "worker_role" {
  value = "${aws_iam_role.eks.arn}"
}
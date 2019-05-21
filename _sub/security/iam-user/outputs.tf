output "arn" {
  value = "${aws_iam_user.user.arn}"
}

output "access_key" {
  value = "${aws_iam_access_key.key.id}"
}

output "secret_key" {
  value     = "${aws_iam_access_key.key.secret}"
  sensitive = true
}

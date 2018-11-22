output "iam_user_name" {
    value = "${aws_iam_user.master_user.name}"
}

output "iam_access_key" {
    value = "${aws_iam_access_key.master_user_key.id}"
}
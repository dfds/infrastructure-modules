output "kiam_server_role_id" {
    value = "${element(concat(aws_iam_role.server_role.*.id, list("")), 0)}"
}

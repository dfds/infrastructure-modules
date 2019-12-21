output "server_role_id" {
  value = element(concat(aws_iam_role.server_role.*.id, [""]), 0)
}

output "server_role_arn" {
  value = local.kiam_server_role_arn
}


output "name" {
  value = "${aws_organizations_account.org_account.name}"
}

output "id" {
  value = "${aws_organizations_account.org_account.id}"
}

output "email" {
  value = "${aws_organizations_account.org_account.email}"
}

output "role_name" {
  value = "${aws_organizations_account.org_account.role_name}"
}

output "role_arn" {
  value = "arn:aws:iam::${aws_organizations_account.org_account.id}:role/${aws_organizations_account.org_account.role_name}"
}

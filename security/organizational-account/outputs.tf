output "email" {
  value = "${aws_organizations_account.dfds.email}"
}
output "aws_account_id" {
  value = "${aws_organizations_account.dfds.id}"
}

output "aws_account_name" {
  value = "${aws_organizations_account.dfds.name}"
}

output "aws_org_role" {
  value = "${var.aws_org_rolename}"
}
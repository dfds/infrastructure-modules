#Outputs the key info about a new account.
#This can be used to access the new account via assume role in case additional changes needs to be made to the account
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
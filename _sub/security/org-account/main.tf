
resource "aws_organizations_account" "org_account_root" {
  name                       = "${lower(var.name)}"
  email                      = "${var.email}"
  iam_user_access_to_billing = "ALLOW"
  role_name                  = "${var.org_role_name}"

#  provisioner "local-exec" {
#   command = "sleep ${var.sleep_after}"
#  }
}


/*
Dirty workaround: It seems that if we create accounts directly in the target OU, the account is not initialised properly:
- Account appears on AWS Orgnaizations account list, but not under Tax Settings
- When assuming OrgRole in the new account from Master, get access_denied on IAM
These issues all seem to be fixed, if the account AT ANY POINT has been in the root OU.
*/

resource "aws_organizations_account" "move_org_account" {
  name                       = "${aws_organizations_account.org_account_root.name}"
  email                      = "${aws_organizations_account.org_account_root.email}"
  iam_user_access_to_billing = "ALLOW"
  role_name                  = "${aws_organizations_account.org_account_root.role_name}
  parent_id                  = "${var.parent_id}"

 provisioner "local-exec" {
  command = "sleep ${var.sleep_after}"
 }
}
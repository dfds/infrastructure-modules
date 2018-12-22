resource "aws_organizations_account" "org_account" {
  name                       = "${var.name}"
  email                      = "${var.email}"
  iam_user_access_to_billing = "ALLOW"
  role_name                  = "${var.org_role_name}"
}
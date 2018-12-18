provider "aws" {
  region = "${var.aws_region}"
  alias  = "workload"

  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.org_account.id}:role/${aws_organizations_account.org_account.role_name}"
    # role_arn = "arn:aws:iam::490910914506:role/OrgRole"
  }
}

resource "aws_organizations_account" "org_account" {
  #Generate an organizational account based on the input from a tfvars file.
  name                       = "${var.name}"
  email                      = "${var.email}"
  iam_user_access_to_billing = "ALLOW"
  role_name                  = "${var.role_name}"
}

resource "aws_iam_account_alias" "org_account" {
  #This will change the current account's alias to the one defined in the tfvars file
  account_alias = "${aws_organizations_account.org_account.name}"
  provider = "aws.workload"
}

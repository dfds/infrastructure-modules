# ----------------------------------------------------------------------------------------------------------------------
# CREATE ALL THE IAM POLICY DOCUMENTS
# We define all of our reusable IAM Policy documents in the iam-policies module.
# ----------------------------------------------------------------------------------------------------------------------

module "iam_policy_create_s3_bucket" {
  source = "../iam-policies"

  aws_account_id = var.aws_account_id
  # allow_access_from_other_account_arns = ["${var.allow_read_only_access_from_other_account_arns}"]

  # Only enable the MFA requirement for the trust policy, which will require MFA to assume the IAM Role, but not the
  # other policies, which would require MFA for individual API calls. The latter doesn't work with aws sts assume-role,
  # and isn't necessary so long as the trust policiy requirement is in place.
  # trust_policy_should_require_mfa = "${var.should_require_mfa}"
  # iam_policy_should_require_mfa   = false
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE PRIME IAM USER
# ----------------------------------------------------------------------------------------------------------------------
# resource "aws_iam_role" "allow_billing_access_from_other_accounts" {
#   count                = "${signum(length(var.allow_billing_access_from_other_account_arns))}"
#   name                 = "${var.billing_access_iam_role_name}"
#   assume_role_policy   = "${module.iam_policies_billing.allow_access_from_other_accounts}"
#   max_session_duration = "${var.max_session_duration_human_users}"
# }
# resource "aws_iam_role_policy" "allow_billing_access_from_other_accounts" {
#   count  = "${signum(length(var.allow_billing_access_from_other_account_arns))}"
#   name   = "allow-billing-access-from-other-accounts-permissions"
#   role   = "${element(aws_iam_role.allow_billing_access_from_other_accounts.*.id, count.index)}"
#   policy = "${module.iam_policies_billing.billing}"
# }

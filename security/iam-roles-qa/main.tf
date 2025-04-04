# Load IAM policy documents from module
module "qa_iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = var.qa_iam_role_trusted_account_root_arn
}

# Create the role for the master account
resource "aws_iam_role" "qa_role" {
  name               = var.qa_iam_role_name
  description        = var.qa_iam_role_description
  assume_role_policy = module.qa_iam_policies.trusted_account

  provider = aws.workload
}

# Create the a role, allowing to create organisation accounts
resource "aws_iam_role_policy" "qa_role_policy" {
  name   = var.qa_iam_policy_name
  role   = aws_iam_role.qa_role.id
  policy = module.qa_iam_policies.admin

  provider = aws.workload
}

# data "aws_caller_identity" "current" {
#   provider = "aws.core"
# }

data "aws_iam_policy_document" "assume_role_policy_self" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.org_account.id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_adfs_shared" {
  statement {
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = [
        "arn:aws:iam::${var.shared_account_id}:saml-provider/ADFS"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

}

data "aws_iam_policy_document" "assume_role_policy_crossplane_provider_aws" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.shared_account_id}:role/provider-aws"]
    }
  }
}
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
data "aws_caller_identity" "current" {
  provider = aws.core
}

data "aws_iam_policy_document" "assume_role_policy_master_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.master_account_id}:user/CerteroEndpointUser"]
    }
  }
}

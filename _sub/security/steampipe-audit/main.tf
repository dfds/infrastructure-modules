resource "aws_iam_role" "steampipe_audit" {
  name               = "steampipe-audit"
  assume_role_policy = data.aws_iam_policy_document.steampipe_audit_assume.json
}

data "aws_iam_policy_document" "steampipe_audit_assume" {
  statement {
    sid    = "assume"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.allowed_account_id}:root"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.allowed_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_${var.allowed_principal_role_name}_*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.steampipe_audit.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "viewonly" {
  role       = aws_iam_role.steampipe_audit.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

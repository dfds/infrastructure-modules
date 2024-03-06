# --------------------------------------------------
# IAM policy and role for external secrets operator
# --------------------------------------------------

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "ssm" {
  statement {
    actions   = ["ssm:GetParameter*", "ssm:DescribeParameters", "tag:GetResources"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${var.aws_region}:${var.workload_account_id}:parameter*"]
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.iam_role_name}-policy"
  description = "Used by IRSA for external secrets operator"
  policy      = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AssumeRoleWithWebIdentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${var.workload_account_id}:oidc-provider/${var.oidc_issuer}",
      ]
    }

    dynamic "condition" {
      for_each = toset(var.allowed_namespaces)
      content {
        test     = "StringLike"
        values   = ["system:serviceaccount:${condition.value}:${var.service_account}"]
        variable = "${var.oidc_issuer}:sub"
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.iam_role_name
  description        = "Used by IRSA for external secrets operator"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

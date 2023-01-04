data "aws_iam_policy_document" "subnet_exporter" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeSubnets",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "subnet_exporter_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_issuer}",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${var.namespace_name}:${local.serviceaccount_name}"]
      variable = "${var.oidc_issuer}:sub"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

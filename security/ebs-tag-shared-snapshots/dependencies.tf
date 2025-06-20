data "aws_iam_policy_document" "ebs_snapshots" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags*"
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}::snapshot/*"
    ]
  }
  dynamic "statement" {
    for_each = var.snapshot_share_kms_arn != "" ? [1] : []

    content {
      effect = "Allow"

      actions = [
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:Decrypt"
      ]

      resources = [
        var.snapshot_share_kms_arn
      ]
    }
  }
}

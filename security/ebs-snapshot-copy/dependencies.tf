data "aws_iam_policy_document" "ebs_snapshots" {
  statement {
    effect = "Allow"

    actions = ["ec2:ModifySnapshotAttribute"]

    resources = [
      "arn:aws:ec2:${var.aws_region}::snapshot/*"
    ]
  }
}
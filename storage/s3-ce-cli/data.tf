data "aws_iam_policy_document" "iam_inventory_role_policy" {
  statement {
    sid    = "CloudEngineeringCLI"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::mybucket"
    ]
  }
}

data "aws_iam_policy_document" "iam_inventory_role_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = ["arn:aws:iam::999999999999:root"]
      type        = "AWS"
    }
  }
}
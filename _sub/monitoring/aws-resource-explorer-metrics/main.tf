resource "aws_iam_role" "resourceexplorer_read" {
  name               = "resourceexplorer-read"
  assume_role_policy = data.aws_iam_policy_document.resourceexplorer_read_assume.json
}

data "aws_iam_policy_document" "resourceexplorer_read_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.allowed_assume_arn]
    }
  }
}

resource "aws_iam_policy" "resourceexplorer_read" {
  name        = "resource-explorer-read"
  description = "Policy used for reading resource explorer info"
  policy      = data.aws_iam_policy_document.resourceexplorer_read.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "resourceexplorer_read" {
  statement {
    effect = "Allow"
    actions = [
      "resource-explorer-2:List*",
      "resource-explorer-2:Get*",
      "resource-explorer-2:Search",
      "resource-explorer-2:BatchGetView",
      "ec2:DescribeRegions",
      "ram:ListResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "resourceexplorer_read" {
  role       = aws_iam_role.resourceexplorer_read.name
  policy_arn = aws_iam_policy.resourceexplorer_read.arn
}

resource "aws_cloudwatch_log_group" "vpc_eks" {
  name              = "/aws/vpc/${var.log_name}"
  retention_in_days = var.retention_in_days
}

data "aws_iam_policy_document" "flow_log_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_log" {
  name               = "vpc-flow-log-${var.log_name}"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume_role.json
}

resource "aws_flow_log" "eks" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_eks.arn
  traffic_type    = "REJECT"
  vpc_id          = var.vpc_id
}

data "aws_iam_policy_document" "flow_log" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_eks.arn}",
      "${aws_cloudwatch_log_group.vpc_eks.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "flow_log" {
  name   = "vpc-flow-log-${var.log_name}"
  role   = aws_iam_role.flow_log.id
  policy = data.aws_iam_policy_document.flow_log.json
}


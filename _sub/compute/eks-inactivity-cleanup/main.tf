resource "aws_cloudwatch_event_rule" "inactivity" {
  name        = "eks-inactivity-${var.eks_cluster_name}"
  description = "Clean up EKS cluster due to inactivity"

  event_pattern = jsonencode({
    "source" : ["aws.cloudwatch"],
    "detail-type" : ["CloudWatch Alarm State Change"],
    "resources" : [var.inactivity_alarm_arn],
    "detail" : {
      "state" : {
        "value" : ["ALARM"]
      }
    }
  })
}

resource "aws_ssm_document" "clean_eks" {
  name            = "clean-eks-${var.eks_cluster_name}"
  document_format = "YAML"
  document_type   = "Automation"

  content = file("${path.module}/documents/delete-eks.yaml")
}

resource "aws_cloudwatch_event_target" "ssm" {
  rule     = aws_cloudwatch_event_rule.inactivity.name
  role_arn = aws_iam_role.issue_clean_eks.arn
  # Work around bug where the API doesn't detect that this is an automation:
  # https://github.com/hashicorp/terraform-provider-aws/issues/6461#issuecomment-510845647
  arn = replace(aws_ssm_document.clean_eks.arn, "document/", "automation-definition/")

  input = jsonencode({
    "AutomationAssumeRole" : [aws_iam_role.exec_clean_eks.arn],
    "EKSClusterName" : [var.eks_cluster_name]
  })

}

data "aws_iam_policy_document" "exec_clean_eks_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ssm.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "exec_clean_eks" {
  statement {
    effect = "Allow"
    actions = [
      "eks:ListNodegroups",
      "eks:DeleteCluster",
    ]
    resources = [var.eks_cluster_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:DeleteNodegroup",
    ]
    resources = [
      "${join(":", slice(split(":", var.eks_cluster_arn), 0, 5))}:nodegroup/${var.eks_cluster_name}/*"
    ]
  }
}

resource "aws_iam_role" "exec_clean_eks" {
  name               = "exec-clean-eks-${var.eks_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.exec_clean_eks_trust.json
}

resource "aws_iam_policy" "exec_clean_eks" {
  name   = "exec-clean-eks-${var.eks_cluster_name}"
  policy = data.aws_iam_policy_document.exec_clean_eks.json
}

resource "aws_iam_role_policy_attachment" "exec_clean_eks" {
  policy_arn = aws_iam_policy.exec_clean_eks.arn
  role       = aws_iam_role.exec_clean_eks.name
}

data "aws_iam_policy_document" "issue_clean_eks_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "issue_clean_eks" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.exec_clean_eks.arn]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      "${aws_ssm_document.clean_eks.arn}:*",
      # Attempts to startu the execution on a resource with the "automation-definition" prefix
      # instead of the "document" prefix:
      "${replace(aws_ssm_document.clean_eks.arn, "document/", "automation-definition/")}:*",
    ]
  }
}

resource "aws_iam_role" "issue_clean_eks" {
  name               = "issue-clean-eks-${var.eks_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.issue_clean_eks_trust.json
}

resource "aws_iam_policy" "issue_clean_eks" {
  name   = "issue-clean-eks-${var.eks_cluster_name}"
  policy = data.aws_iam_policy_document.issue_clean_eks.json
}

resource "aws_iam_role_policy_attachment" "issue_clean_eks" {
  policy_arn = aws_iam_policy.issue_clean_eks.arn
  role       = aws_iam_role.issue_clean_eks.name
}

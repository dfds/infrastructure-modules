resource "aws_cloudwatch_event_rule" "inactivity" {
  name        = "elb-inactivity-${var.elb_name}"
  description = "Clean up ELB load balancer due to inactivity"

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

resource "aws_ssm_document" "clean_elb" {
  name          = "clean_elb_${var.elb_name}"
  document_type = "Automation"

  content = jsonencode({
    "description" : "Delete ELB load balancer",
    "schemaVersion" : "0.3",
    "assumeRole" : "{{ AutomationAssumeRole }}",
    "parameters" : {
      "AutomationAssumeRole" : {
        "type" : "String",
        "description" : "(Required) The ARN of the role that allows Automation to perform\nthe actions on your behalf. If no role is specified, Systems Manager Automation\nuses your IAM permissions to run this runbook.",
        "allowedPattern" : "^arn:aws(-cn|-us-gov)?:iam::\\d{12}:role/[\\w+=,.@-]+|^$"
      },
      "LoadBalancerArn" : {
        "type" : "String",
        "description" : "(Required) The ARN of the load balancer.",
      }
    },
    "mainSteps" : [
      {
        "name" : "deleteElb",
        "action" : "aws:executeAwsApi",
        "onFailure" : "Abort",
        "inputs" : {
          "Service" : "elbv2",
          "Api" : "DeleteLoadBalancer",
          "LoadBalancerArn" : "{{ LoadBalancerArn }}",
        }
      },
    ],
  })
}

resource "aws_cloudwatch_event_target" "ssm" {
  rule     = aws_cloudwatch_event_rule.inactivity.name
  role_arn = aws_iam_role.issue_clean_elb.arn
  # Work around bug where the API doesn't detect that this is an automation:
  # https://github.com/hashicorp/terraform-provider-aws/issues/6461#issuecomment-510845647
  arn = replace(aws_ssm_document.clean_elb.arn, "document/", "automation-definition/")

  input = jsonencode({
    "AutomationAssumeRole" : [aws_iam_role.exec_clean_elb.arn],
    "LoadBalancerArn" : [var.elb_arn]
  })

}

data "aws_iam_policy_document" "exec_clean_elb_trust" {
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

data "aws_iam_policy_document" "exec_clean_elb" {
  statement {
    effect  = "Allow"
    actions = ["elasticloadbalancing:DeleteLoadBalancer"]
    resources = [
      var.elb_arn,
      "${join("/", slice(split("/", var.elb_arn), 0, 1))}/${var.elb_name}"
    ]
  }
}

resource "aws_iam_role" "exec_clean_elb" {
  name               = "exec-clean-elb-${var.elb_name}"
  assume_role_policy = data.aws_iam_policy_document.exec_clean_elb_trust.json
}

resource "aws_iam_policy" "exec_clean_elb" {
  name   = "exec-clean-elb-${var.elb_name}"
  policy = data.aws_iam_policy_document.exec_clean_elb.json
}

resource "aws_iam_role_policy_attachment" "exec_clean_elb" {
  policy_arn = aws_iam_policy.exec_clean_elb.arn
  role       = aws_iam_role.exec_clean_elb.name
}

data "aws_iam_policy_document" "issue_clean_elb_trust" {
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

data "aws_iam_policy_document" "issue_clean_elb" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.exec_clean_elb.arn]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      "${aws_ssm_document.clean_elb.arn}:*",
      # Attempts to start the execution on a resource with the "automation-definition" prefix
      # instead of the "document" prefix:
      "${replace(aws_ssm_document.clean_elb.arn, "document/", "automation-definition/")}:*",
    ]
  }
}

resource "aws_iam_role" "issue_clean_elb" {
  name               = "issue-clean-elb-${var.elb_name}"
  assume_role_policy = data.aws_iam_policy_document.issue_clean_elb_trust.json
}

resource "aws_iam_policy" "issue_clean_elb" {
  name   = "issue-clean-elb-${var.elb_name}"
  policy = data.aws_iam_policy_document.issue_clean_elb.json
}

resource "aws_iam_role_policy_attachment" "issue_clean_elb" {
  policy_arn = aws_iam_policy.issue_clean_elb.arn
  role       = aws_iam_role.issue_clean_elb.name
}

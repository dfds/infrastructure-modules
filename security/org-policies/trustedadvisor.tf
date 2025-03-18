data "aws_iam_policy_document" "trustedadvisor" {
  statement {
    sid    = "TrustedAdvisorPolicies"
    effect = "Deny"
    not_actions = [
      "trustedadvisor:DescribeAccount*",
      "trustedadvisor:DescribeChecks",
      "trustedadvisor:DescribeCheckSummaries",
      "trustedadvisor:DescribeCheckRefreshStatuses"
    ]
    resources = ["*"]
    condition {
      test = "StringNotLike"
      values = [
        "eu-central-1",
        "eu-west-1",
      ]
      variable = "aws:RequestedRegion"
    }
  }


}

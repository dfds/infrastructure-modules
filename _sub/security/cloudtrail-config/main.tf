resource "aws_cloudwatch_log_group" "log_group" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "/cloudtrail/${var.trail_name}"
}

data "aws_iam_policy_document" "trust" {
  count = var.deploy && var.create_log_group ? 1 : 0

  statement {
    sid     = "AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "ct-cw-role-${var.trail_name}"

  assume_role_policy = data.aws_iam_policy_document.trust[count.index].json
}

data "aws_iam_policy_document" "logs" {
  count = var.deploy && var.create_log_group ? 1 : 0

  statement {
    sid       = "CreateLogStream"
    actions   = ["logs:CreateLogStream"]
    resources = ["${aws_cloudwatch_log_group.log_group[count.index].arn}:*"]
  }

  statement {
    sid       = "PutLogEvents"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log_group[count.index].arn}:*"]
  }
}

resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "ct-cw-policy-${var.trail_name}"
  role  = aws_iam_role.cloudtrail_to_cloudwatch[count.index].id

  policy = data.aws_iam_policy_document.logs[count.index].json
}

# tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption tfsec:ignore:aws-cloudtrail-ensure-cloudwatch-integration
resource "aws_cloudtrail" "cloudtrail" {
  count                         = var.deploy ? 1 : 0
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_trail
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true
  cloud_watch_logs_role_arn     = try(aws_iam_role.cloudtrail_to_cloudwatch[0].arn, null)
  cloud_watch_logs_group_arn    = try("${aws_cloudwatch_log_group.log_group[0].arn}:*", null)
}

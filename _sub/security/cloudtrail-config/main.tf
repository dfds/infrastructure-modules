resource "aws_cloudwatch_log_group" "log_group" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "/cloudtrail/${var.trail_name}"
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "ct-cw-role-${var.trail_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "ct-cw-policy-${var.trail_name}"
  role  = aws_iam_role.cloudtrail_to_cloudwatch[count.index].id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.log_group[count.index].arn}:*"
            ]
        },
        {
            "Sid": "PutLogEvents",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.log_group[count.index].arn}:*"
            ]
        }
    ]
}
EOF
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

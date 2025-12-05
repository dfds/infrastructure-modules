
module "lambda" {
  source             = "../../_sub/compute/lambda/lambda-from-archive"
  filename_out       = "${path.module}/lambda.zip"
  path_to_index_file = "${path.module}/src/index.js"
  name               = "ebs-snapshot-share"
  function_environment_variables = {
    RUN_AWS_REGION       = var.aws_region
    DESTINATION_ACCOUNTS = join(",", var.snapshot_share_destination_accounts)
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "capture-snapshot-created-event"
  description = "Capture each EBS Snapshot Created"

  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EBS Snapshot Notification"],
  "detail": {
    "result": ["succeeded"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "TriggerLambda"
  arn       = module.lambda.arn
}

module "trigger_lambda_permission" {
  source        = "../../_sub/compute/lambda/run-lambda-permission"
  function_name = module.lambda.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

resource "aws_iam_role_policy" "ebs_snapshots" {
  name   = "ebs-snapshot-share"
  role   = module.lambda.role_name
  policy = data.aws_iam_policy_document.ebs_snapshots.json
}

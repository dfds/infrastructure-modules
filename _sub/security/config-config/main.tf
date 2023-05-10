# Policies

data "aws_iam_policy_document" "recorder" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "assume_recorder_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "recorder" {
  name               = "aws-config-recorder"
  assume_role_policy = data.aws_iam_policy_document.assume_recorder_role.json
}

resource "aws_iam_role_policy" "recorder" {
  name   = "aws-config-recorder"
  role   = aws_iam_role.recorder.id
  policy = data.aws_iam_policy_document.recorder.json
}

resource "aws_iam_role_policy_attachment" "recorder" {
  role       = aws_iam_role.recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config

resource "aws_config_configuration_recorder" "this" {
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.recorder.arn
}

resource "aws_config_delivery_channel" "this" {
  name           = "aws-config-delivery-channel"
  s3_bucket_name = var.s3_bucket_name
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

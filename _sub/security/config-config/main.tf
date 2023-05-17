# Policies

data "aws_iam_policy_document" "recorder" {
  count = var.deploy ? 1 : 0

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
  count = var.deploy ? 1 : 0

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
  count              = var.deploy ? 1 : 0
  name_prefix        = "aws-config-recorder"
  assume_role_policy = data.aws_iam_policy_document.assume_recorder_role[count.index].json
}

resource "aws_iam_role_policy" "recorder" {
  count       = var.deploy ? 1 : 0
  name_prefix = "aws-config-recorder"
  role        = aws_iam_role.recorder[count.index].id
  policy      = data.aws_iam_policy_document.recorder[count.index].json
}

resource "aws_iam_role_policy_attachment" "recorder" {
  count      = var.deploy ? 1 : 0
  role       = aws_iam_role.recorder[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config

resource "aws_config_configuration_recorder" "this" {
  count    = var.deploy ? 1 : 0
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.recorder[count.index].arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  count          = var.deploy ? 1 : 0
  name           = "aws-config-delivery-channel"
  s3_bucket_name = var.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count      = var.deploy ? 1 : 0
  name       = aws_config_configuration_recorder.this[count.index].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

# Conformance packs

resource "aws_config_conformance_pack" "pack" {
  for_each = var.deploy ? var.conformance_packs : []
  name     = replace(lower(each.value), "/[^a-z0-9-]/", "-")

  # Conformance packs can be imported from this repository:
  # https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs
  template_body = file("${path.module}/conformance-packs/${each.value}.yaml")

  depends_on = [aws_config_configuration_recorder.this]
}

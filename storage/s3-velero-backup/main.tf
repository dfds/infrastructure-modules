# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "velero_storage" {
  bucket        = var.bucket_name
  force_destroy = var.force_bucket_destroy

  tags = merge(
    var.additional_tags,
    {
      "Managed by" = "Terraform"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "veloro_storage_block_public_access" {
  bucket                  = aws_s3_bucket.velero_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.velero_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.velero_storage.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.velero_storage.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_public_access_block.veloro_storage_block_public_access,
    aws_s3_bucket_ownership_controls.bucket_ownership_controls,
  ]
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.velero_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count  = var.velero_role_arn != null ? 1 : 0
  bucket = aws_s3_bucket.velero_storage.id
  policy = data.aws_iam_policy_document.allow_access_from_assumed_rule[0].json
}

data "aws_iam_policy_document" "allow_access_from_assumed_rule" {
  count = var.velero_role_arn != null ? 1 : 0
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.velero_role_arn]
    }

    sid     = "Bucket permissions"
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.velero_storage.arn,
      "${aws_s3_bucket.velero_storage.arn}/*",
    ]
  }
}

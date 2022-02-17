terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

# Only create a IAM Provider for OIDC if var.oidc_provider_url is supplied.
# If var.oidc_provider_url is not supplied, it means that one already exist,
# and information is fetched through the EKS data source.
resource "aws_iam_openid_connect_provider" "oidc_iam_provider" {
  count           = var.oidc_provider_url != null ? 1 : 0
  url             = local.oidc_provider_url
  client_id_list  = ["sts.amazonaws.com", ]
  thumbprint_list = [local.oidc_provider_thumbprints]
}

resource "aws_s3_bucket" "velero_storage" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = var.force_bucket_destroy
  versioning {
    enabled = var.versioning
  }
}

resource "aws_s3_bucket_public_access_block" "veloro_storage_block_public_access" {
  bucket = aws_s3_bucket.velero_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "velero_policy" {
  name        = "VeleroPolicy"
  description = "Policy for Velero backups"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "${aws_s3_bucket.velero_storage.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.velero_storage.arn}"
            ]
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["${local.oidc_provider_arn}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_server_id}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }
  }
}

resource "aws_iam_role" "velero_role" {
  name               = var.velero_iam_role_name
  description        = ""
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "velero_policy_attach" {
  role       = aws_iam_role.velero_role.name
  policy_arn = aws_iam_policy.velero_policy.arn
}

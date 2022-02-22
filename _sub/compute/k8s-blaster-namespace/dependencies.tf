
data "aws_caller_identity" "workload_account" {
}

locals {
  k8s_janitor_serviceaccount_name = "k8s-janitor-sa"
}

data "aws_iam_policy_document" "k8s_janitor" {
  count = var.deploy ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]

    resources = ["arn:aws:s3:::${var.blaster_configmap_bucket}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = ["arn:aws:s3:::${var.blaster_configmap_bucket}"]
  }
}

data "aws_iam_policy_document" "k8s_janitor_trust" {
  count = var.deploy ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.workload_account.account_id}:oidc-provider/${var.oidc_issuer}",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${kubernetes_namespace.self_service[0].metadata[0].name}:${local.k8s_janitor_serviceaccount_name}"]
      variable = "${var.oidc_issuer}:sub"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

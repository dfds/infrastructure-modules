locals {
  self_service_role     = [element(concat(aws_iam_role.self_service.*.arn, [""]), 0)]
  permitted_roles       = concat(local.self_service_role, var.extra_permitted_roles)
  permitted_roles_regex = join("|", local.permitted_roles)
}

resource "kubernetes_namespace" "self_service" {
  count = var.deploy ? 1 : 0

  metadata {
    annotations = {
      "iam.amazonaws.com/permitted" = local.permitted_roles_regex
    }

    name = "selfservice"
  }
}

resource "aws_iam_role" "self_service" {
  count = var.deploy ? 1 : 0
  name  = "eks-${var.cluster_name}-self-service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${var.kiam_server_role_arn}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "rolemapperservice" {
  count       = var.deploy ? 1 : 0
  name        = "eks-${var.cluster_name}-rolemapperservice"
  description = "Permissions for the role mapper service"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
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
            ],
            "Resource": "arn:aws:s3:::${var.blaster_configmap_bucket}/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${var.blaster_configmap_bucket}",
            "Effect": "Allow"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "rolemapperservice" {
  count      = var.deploy ? 1 : 0
  role       = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
  policy_arn = element(concat(aws_iam_policy.rolemapperservice.*.arn, [""]), 0)
}

resource "aws_iam_policy" "param_store" {
  count       = var.deploy ? 1 : 0
  name        = "eks-${var.cluster_name}-param-store"
  description = "Permissions for kube configs in param-store"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:ListTagsForResource",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-1:*:parameter/eks/${var.cluster_name}/default_user"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "param-store" {
  count      = var.deploy ? 1 : 0
  role       = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
  policy_arn = element(concat(aws_iam_policy.param_store.*.arn, [""]), 0)
}

# --------------------------------------------------
# k8s-janitor IAM role
# --------------------------------------------------

locals {
  k8s_janitor_iam_role_name = "k8s-janitor"
}

resource "aws_iam_role" "k8s_janitor" {
  count                = var.deploy ? 1 : 0
  name                 = local.k8s_janitor_iam_role_name
  path                 = "/"
  description          = "Role for k8s-janitor to manage S3 buckets within its path"
  assume_role_policy   = data.aws_iam_policy_document.k8s_janitor_trust[0].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "k8s_janitor" {
  count  = var.deploy ? 1 : 0
  name   = local.k8s_janitor_iam_role_name
  role   = aws_iam_role.k8s_janitor[0].id
  policy = data.aws_iam_policy_document.k8s_janitor[0].json
}
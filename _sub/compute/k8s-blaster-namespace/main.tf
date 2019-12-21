resource "kubernetes_namespace" "self_service" {
  count = var.deploy

  metadata {
    annotations = {
      "iam.amazonaws.com/permitted" = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
    }

    name = "selfservice"
  }
}

resource "aws_iam_role" "self_service" {
  count = var.deploy
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

resource "aws_iam_policy" "iamroleservice" {
  count       = var.deploy
  name        = "iamroleservice"
  description = "Permissions for the iam role service"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:*",
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "iamroleservice" {
  count      = var.deploy
  role       = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
  policy_arn = element(concat(aws_iam_policy.iamroleservice.*.arn, [""]), 0)
}

resource "aws_iam_policy" "rolemapperservice" {
  count       = var.deploy
  name        = "rolemapperservice"
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
  count      = var.deploy
  role       = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
  policy_arn = element(concat(aws_iam_policy.rolemapperservice.*.arn, [""]), 0)
}

resource "aws_iam_policy" "param_store" {
  count       = var.deploy
  name        = "param-store"
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
  count      = var.deploy
  role       = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
  policy_arn = element(concat(aws_iam_policy.param_store.*.arn, [""]), 0)
}

resource "aws_iam_policy" "argocdjanitor" {
  count       = var.deploy
  name        = "argocdjanitor"
  description = "Permissions for argocd password"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters"
            ],
            "Resource": "arn:aws:ssm:eu-west-1:*:parameter/eks/${var.cluster_name}/argocd_admin"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "argocdjanitor" {
  count      = var.deploy
  role       = element(concat(aws_iam_role.self_service.*.name, [""]), 0)
  policy_arn = element(concat(aws_iam_policy.argocdjanitor.*.arn, [""]), 0)
}


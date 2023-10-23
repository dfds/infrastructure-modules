# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

resource "github_repository_file" "velero_flux_helm_path" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = jsonencode(local.app_helm_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_init" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = jsonencode(local.helm_init)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_patch_yaml" {
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.helm_repo_path}/patch.yaml"
  content             = local.helm_patch_yaml
  overwrite_on_create = var.overwrite_on_create
}


# --------------------------------------------------
# IAM policy and role for Velero
# --------------------------------------------------

# tfsec:ignore:aws-iam-no-policy-wildcards
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
                "${var.bucket_arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${var.bucket_arn}"
            ]
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AssumeRoleWithWebIdentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${var.workload_account_id}:oidc-provider/${var.oidc_issuer}",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
      variable = "${var.oidc_issuer}:sub"
    }
  }
}

resource "aws_iam_role" "velero_role" {
  name               = var.velero_iam_role_name
  description        = "Used by IRSA for Velero"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "velero_policy_attach" {
  role       = aws_iam_role.velero_role.name
  policy_arn = aws_iam_policy.velero_policy.arn
}

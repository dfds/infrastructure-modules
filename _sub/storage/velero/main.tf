# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

# --------------------------------------------------
# Create JSON files to be picked up by Flux CD
# --------------------------------------------------

resource "github_repository_file" "velero_flux_helm_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    app_install_name                = local.app_install_name
    helm_repo_path                  = local.helm_repo_path
    deploy_name                     = local.deploy_name
    access_mode                     = var.access_mode
    bucket_name                     = local.bucket_name
    aws_region                      = var.aws_region
    azure_bucket_name               = var.azure_bucket_name
    azure_resource_group            = var.azure_resource_group_name
    azure_storage_account           = var.azure_storage_account_name
    azure_subscription_id           = var.azure_subscription_id
    cluster_backup_disabled         = var.cluster_backup_disabled
    cluster_backup_offsite_disabled = var.cluster_backup_offsite_disabled
    cluster_name                    = var.cluster_name
    iam_role_arn                    = aws_iam_role.velero_role.arn
    patch_file                      = local.patch_file
    prune                           = var.prune
  })
  overwrite_on_create = true
}

resource "github_repository_file" "velero_flux_helm_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url                 = var.gitops_apps_repo_url
    deploy_name                          = local.deploy_name
    gitops_apps_repo_ref                 = var.gitops_apps_repo_ref
    enable_azure_storage_external_secret = var.enable_azure_storage_external_secret
  })
  overwrite_on_create = true
}

resource "github_repository_file" "velero_flux_helm_secret_store" {
  count               = var.enable_azure_storage_external_secret ? 1 : 0
  repository          = var.repo_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.helm_repo_path}/secret-store.yaml"
  content             = templatefile("${path.module}/values/secret-store.yaml", {})
  overwrite_on_create = true
}

resource "github_repository_file" "velero_flux_helm_external_secret" {
  count      = var.enable_azure_storage_external_secret ? 1 : 0
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/external-secret.yaml"
  content = templatefile("${path.module}/values/external-secret.yaml", {
    cluster_name = var.cluster_name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "velero_flux_helm_service_account" {
  count      = var.enable_azure_storage_external_secret ? 1 : 0
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/service-account.yaml"
  content = templatefile("${path.module}/values/service-account.yaml", {
    velero_ssm_role_arn = var.velero_ssm_role_arn
  })
  overwrite_on_create = true
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
      values   = ["system:serviceaccount:velero:velero-server"]
      variable = "${var.oidc_issuer}:sub"
    }
  }
}

resource "aws_iam_role" "velero_role" {
  name               = local.velero_iam_role_name
  description        = "Used by IRSA for Velero"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "velero_policy_attach" {
  role       = aws_iam_role.velero_role.name
  policy_arn = aws_iam_policy.velero_policy.arn
}

resource "aws_iam_policy" "kms_policy" {
  count       = var.ebs_csi_kms_arn != "" ? 1 : 0
  name        = "KMSAccess"
  description = "Policy for KMS access"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:RevokeGrant",
                "kms:ListGrants",
                "kms:CreateGrant"
            ],
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            },
            "Effect": "Allow",
            "Resource": "${var.ebs_csi_kms_arn}"
        },
        {
            "Action": [
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": "${var.ebs_csi_kms_arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kms_policy_attach" {
  count      = var.ebs_csi_kms_arn != "" ? 1 : 0
  role       = aws_iam_role.velero_role.name
  policy_arn = aws_iam_policy.kms_policy[count.index].arn
}

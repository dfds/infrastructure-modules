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
    app_install_name = local.app_install_name
    helm_repo_path   = local.helm_repo_path
    deploy_name      = var.deploy_name
    namespace        = var.namespace
    prune            = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
    enable_azure_storage_external_secret = var.enable_azure_storage_external_secret
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_patch_yaml" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    helm_chart_version                  = var.helm_chart_version
    helm_repo_name                      = var.helm_repo_name
    image_tag                           = var.image_tag
    snapshots_enabled                   = var.snapshots_enabled
    node_agent_enabled                  = var.node_agent_enabled
    plugin_for_aws_version              = var.plugin_for_aws_version
    plugin_for_azure_version            = var.plugin_for_azure_version
    log_level                           = var.log_level
    bucket_name                         = local.bucket_name
    bucket_region                       = var.bucket_region
    velero_role_arn                     = aws_iam_role.velero_role.arn
    cluster_name                        = var.cluster_name
    cron_schedule                       = var.cron_schedule
    schedules_template_ttl              = var.schedules_template_ttl
    excluded_cluster_scoped_resources   = var.excluded_cluster_scoped_resources
    excluded_namespace_scoped_resources = var.excluded_namespace_scoped_resources
    read_only                           = var.read_only
    azure_resource_group_name           = var.azure_resource_group_name
    azure_storage_account_name          = var.azure_storage_account_name
    azure_subscription_id               = var.azure_subscription_id
    azure_bucket_name                   = var.azure_bucket_name
    azure_credentials_secret_name       = var.azure_credentials_secret_name
    azure_credentials_secret_key        = var.azure_credentials_secret_key
    enable_azure_storage                = var.enable_azure_storage
    cron_schedule_offsite               = var.cron_schedule_offsite
    cron_schedule_offsite_ttl           = var.cron_schedule_offsite_ttl
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_secret_store" {
  count      = var.enable_azure_storage_external_secret ? 1 : 0
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/secret-store.yaml"
  content = templatefile("${path.module}/values/secret-store.yaml", {})
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_external_secret" {
  count      = var.enable_azure_storage_external_secret ? 1 : 0
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/external-secret.yaml"
  content = templatefile("${path.module}/values/external-secret.yaml", {})
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "velero_flux_helm_service_account" {
  count      = var.enable_azure_storage_external_secret ? 1 : 0
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.helm_repo_path}/service-account.yaml"
  content = templatefile("${path.module}/values/service-account.yaml", {
    velero_ssm_role_arn = var.velero_ssm_role_arn
  })
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

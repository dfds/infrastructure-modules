# --------------------------------------------------
# Create YAML files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "external-secrets_helm" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = local.app_helm_path
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-secrets_helm_install" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = local.helm_install
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "external-secrets_helm_patch" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/patch.yaml"
  content             = local.helm_patch
  overwrite_on_create = var.overwrite_on_create
}

# --------------------------------------------------
# IAM policy and role for external secrets operator
# --------------------------------------------------

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "this" {
  name        = "${var.iam_role_name}-policy"
  description = "Used by IRSA for external secrets operator"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter*",
                "ssm:DescribeParameters",
                "tag:GetResources"
            ],
            "Resource": "arn:aws:ssm:eu-west-1:${var.workload_account_id}:parameter*"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "this" {
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

    dynamic "condition" {
      for_each = toset(var.allowed_namespaces)
      content {
        test     = "StringLike"
        values   = ["system:serviceaccount:${condition.value}:${var.service_account}"]
        variable = "${var.oidc_issuer}:sub"
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.iam_role_name
  description        = "Used by IRSA for external secrets operator"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

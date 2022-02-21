# --------------------------------------------------
# fluentd for cloudwatch
# --------------------------------------------------

resource "github_repository_file" "fluentd-cloudwatch_config_init" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content    = jsonencode(local.config_init)
}

resource "github_repository_file" "fluentd-cloudwatch_config_patch_yaml" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.config_repo_path}/patch.yaml"
  content    = local.config_patch_yaml
}

resource "github_repository_file" "fluentd-cloudwatch_config_path" {
  repository = var.repo_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content    = jsonencode(local.app_config_path)
}


# define openid connect provider that is bound to the provider URL for the EKS cluster
resource "aws_iam_openid_connect_provider" "this" {
  count = var.deploy_oidc_provider ? 1 : 0
  url   = var.eks_openid_connect_provider_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]
}

locals {
  role_name = "eks-${var.cluster_name}-cloudwatchlogs"
}

# create IAM role
resource "aws_iam_role" "this" {
  name               = local.role_name
  path               = "/"
  description        = "Role for FluentD to assume in order to ship logs to CloudWatch Logs"
  assume_role_policy = data.aws_iam_policy_document.this_trust.json
}

resource "aws_iam_role_policy" "this" {
  name   = "CloudWatchLogs"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}

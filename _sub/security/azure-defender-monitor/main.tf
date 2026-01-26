data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "azure_defender" {
  url             = "https://sts.windows.net/${local.aad_tenant_id}/"
  client_id_list  = var.oidc_client_id_list
  thumbprint_list = var.oidc_thumbprint_list
}

resource "aws_iam_role" "azure_defender_monitor" {
  name               = local.azure_defender_monitor_role_name
  description        = "Azure Defender for Cloud ready only role"
  assume_role_policy = data.aws_iam_policy_document.azure_defender_monitor_trust.json
}

data "aws_iam_policy_document" "azure_defender_monitor_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/sts.windows.net/${local.aad_tenant_id}/"]
    }

    dynamic "condition" {
      for_each = [
        {
          test     = "StringLike"
          variable = "sts.windows.net/${local.aad_tenant_id}/:aud"
          values   = var.oidc_client_id_list
        },
        {
          test     = "StringLike"
          variable = "sts:RoleSessionName"
          values   = ["MicrosoftDefenderForClouds_73a99466-ad05-4221-9f90-e7142aa2f6c1"]
        }
      ]
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "azure_defender_monitor_read_only" {
  role       = aws_iam_role.azure_defender_monitor.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "azure_defender_monitor" {
  statement {
    effect = "Deny"
    actions = [
      "consolidatedbilling:*",
      "freetier:*",
      "invoicing:*",
      "payments:*",
      "billing:*",
      "tax:*",
      "cur:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "azure_defender_monitor_deny" {
  name        = "${local.azure_defender_monitor_role_name}-deny-policy"
  description = "Deny policy for Azure Defender for Cloud read only role"
  policy      = data.aws_iam_policy_document.azure_defender_monitor.json

}

resource "aws_iam_role_policy_attachment" "azure_defender_monitor_deny" {
  role       = aws_iam_role.azure_defender_monitor.name
  policy_arn = aws_iam_policy.azure_defender_monitor_deny.arn
}

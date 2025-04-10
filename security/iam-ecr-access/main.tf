# --------------------------------------------------
# Flux CD source controller ECR access through IRSA
# --------------------------------------------------

locals {
  fluxcd_role_trust = merge(
    var.fluxcd_role_prod_trust,
    var.fluxcd_role_nonprod_trust
  )
}

data "aws_iam_policy_document" "fluxcd_role_trust" {
  dynamic "statement" {
    for_each = local.fluxcd_role_trust
    content {
      sid     = replace(statement.key, "-", "") # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_sid.html
      effect  = statement.value["effect"]
      actions = [statement.value["action"]]
      principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::${var.aws_workload_account_id}:oidc-provider/${statement.value["oidc_fqdn_url"]}"]
      }
      condition {
        test     = statement.value["condition_operator"]
        variable = "${statement.value["oidc_fqdn_url"]}:${statement.value["condition_variable"]}"
        values   = [statement.value["condition_values"]]
      }
    }
  }
}

resource "aws_iam_role" "fluxcd_role" {
  name               = var.fluxcd_role_name
  description        = "IAM role for ECR access from FluxCD source controller"
  assume_role_policy = data.aws_iam_policy_document.fluxcd_role_trust.json
  tags               = var.tags

  provider = aws.workload
}

resource "aws_iam_role_policy_attachment" "fluxcd_read_only" {
  role       = aws_iam_role.fluxcd_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

  provider = aws.workload
}

# --------------------------------------------------
# OIDC providers for non-prod EKS clusters
# --------------------------------------------------

data "tls_certificate" "cert" {
  for_each = var.fluxcd_role_nonprod_trust
  url      = format("https://%s", each.value["oidc_fqdn_url"])
}

resource "aws_iam_openid_connect_provider" "default" {
  for_each = var.fluxcd_role_nonprod_trust
  url      = format("https://%s", each.value["oidc_fqdn_url"])

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.cert[each.key].certificates[0].sha1_fingerprint]

  tags = merge(var.tags, { Cluster = each.key })

  provider = aws.workload
}

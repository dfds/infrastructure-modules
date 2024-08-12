data "aws_organizations_organization" "this" {}

data "aws_iam_policy_document" "IAMRA" {
  statement {
    sid    = "AllowACMAccess"
    effect = "Allow"
    actions = [
      "acm:ImportCertificate"
    ]
    resources = formatlist("arn:aws:acm:*:%s:certificate/*", var.pca_account_ids)

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.this.id
      ]
    }
  }

  statement {
    sid    = "AllowIssueCertificate"
    effect = "Allow"
    actions = [
      "acm-pca:IssueCertificate"
    ]
    resources = var.private_ca_arns
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.this.id
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "acm-pca:TemplateArn"
      values = [
        "arn:aws:acm-pca:::template/EndEntityCertificate/V1"
      ]
    }
  }

  statement {
    sid    = "AllowPCAAccess"
    effect = "Allow"
    actions = [
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:GetCertificate",
      "acm-pca:GetCertificateAuthorityCertificate",
      "acm-pca:ListPermissions",
      "acm-pca:ListTags"
    ]
    resources = var.private_ca_arns
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.this.id
      ]
    }
  }
}

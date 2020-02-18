resource "aws_iam_saml_provider" "adfs" {
  name                   = var.provider_name
  saml_metadata_document = data.http.federation_metadata.body
}

// Asume role with SAML policy document
data "aws_iam_policy_document" "adfs_assume" {
  statement {
    sid     = var.provider_name
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_saml_provider.adfs.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

data "aws_iam_policy_document" "adfs_role_assume" {
  statement {
    sid     = var.provider_name
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_saml_provider.adfs.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    sid     = "RoleArns"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.assume_role_arns
    }
  }
}


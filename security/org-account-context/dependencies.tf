data "aws_iam_policy_document" "assume_role_policy_self" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.org_account.id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_selfservice" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.shared_account_id}:role/aad-aws-sync"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_ssuk8s" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.ssu_account_id}:role/ssu-k8s"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_selfservice_api" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.shared_account_id}:role/selfservice-api"]
    }
  }
}

data "aws_iam_policy_document" "shared_role_cap_acc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.org_account.id}:root"]
    }
  }

  dynamic "statement" {
    for_each = var.oidc_provider
    content {
      sid     = "AssumeRoleWithWebIdentity4${statement.key}"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      effect  = "Allow"

      principals {
        type = "Federated"

        identifiers = [
          "arn:aws:iam::${statement.value["account_id"]}:oidc-provider/${trim(statement.value["cluster_oidc_url"], "https://")}",
        ]
      }

      condition {
        test     = "StringEquals"
        values   = ["system:serviceaccount:${var.capability_root_id}:ssm-shared-platform-secrets"]
        variable = "${trim(statement.value["cluster_oidc_url"], "https://")}:sub"
      }
    }
  }

  dynamic "statement" {
    for_each = var.oidc_provider_cross_cluster
    content {
      sid     = "AssumeRoleWithWebIdentity4${statement.key}"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      effect  = "Allow"

      principals {
        type = "Federated"

        identifiers = [
          "arn:aws:iam::${statement.value["account_id"]}:oidc-provider/${trim(statement.value["cluster_oidc_url"], "https://")}",
        ]
      }

      condition {
        test     = "StringEquals"
        values   = ["system:serviceaccount:${var.capability_root_id}:ssm-shared-platform-secrets"]
        variable = "${trim(statement.value["cluster_oidc_url"], "https://")}:sub"
      }
    }
  }
}

########################################################################
# Tagging
########################################################################

locals {
  all_tags = {
    "dfds.automation.tool" : "Terraform",
    "dfds.owner" : "Cloud Engineering",
    "dfds.automation.initiator.location" : "https://github.com/dfds/aws-account-manifests"
  }
}

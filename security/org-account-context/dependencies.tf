# data "aws_caller_identity" "current" {
#   provider = "aws.core"
# }

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

// Gives access to role through the individual Capability account
data "aws_iam_policy_document" "shared_role_cap_acc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.org_account.id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_master_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.master_account_id}:user/CerteroEndpointUser"]
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
data "aws_iam_policy_document" "reservation" {

  statement {
    sid    = "ECSDenyAccessToRI"
    effect = "Deny"
    actions = [
      "ec2:PurchaseReservedInstancesOffering",
      "ec2:AcceptReservedInstancesExchangeQuote",
      "ec2:CancelCapacityReservation",
      "ec2:CancelReservedInstancesListing",
      "ec2:CreateCapacityReservation",
      "ec2:CreateReservedInstancesListing",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid       = "RDSDenyAccessToRI"
    effect    = "Deny"
    actions   = ["rds:PurchaseReservedDBInstancesOffering"]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid       = "ElastiCacheDenyAccessToRI"
    effect    = "Deny"
    actions   = ["elasticache:PurchaseReservedCacheNodesOffering"]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "ESDenyAccessToRI"
    effect = "Deny"
    actions = [
      "es:PurchaseReservedElasticsearchInstanceOffering",
      "es:PurchaseReservedInstanceOffering",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid       = "RedShiftDenyAccessToRI"
    effect    = "Deny"
    actions   = ["redshift:PurchaseReservedNodeOffering"]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid       = "DynamoDbDenyAccessToRI"
    effect    = "Deny"
    actions   = ["dynamodb:PurchaseReservedCapacityOfferings"]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }
}

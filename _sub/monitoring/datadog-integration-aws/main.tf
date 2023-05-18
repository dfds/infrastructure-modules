resource "datadog_integration_aws" "account" {
  count                            = var.deploy ? 1 : 0
  account_id                       = var.aws_account_id
  role_name                        = var.datadog_integration_role_name # Not referenced via module.datadog_iam_role to avoid cyclic dependency
  filter_tags                      = var.filter_tags
  host_tags                        = var.host_tags
  account_specific_namespace_rules = var.account_specific_namespace_rules
  metrics_collection_enabled       = var.metrics_collection_enabled
  resource_collection_enabled      = var.resource_collection_enabled
  excluded_regions                 = ["us-east-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1", "af-south-1", "ap-east-1", "ap-northeast-1", "ap-northeast-2", "ap-northeast-3", "ap-south-1", "ap-south-2", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ap-southeast-4", "eu-north-1", "eu-central-2", "eu-south-1", "eu-south-2", "eu-west-2", "eu-west-3", "me-central-1", "me-south-1", "sa-east-1"]
}

module "datadog_iam_role" {
  count              = var.deploy ? 1 : 0
  source             = "../..//security//iam-role"
  role_name          = var.datadog_integration_role_name
  role_description   = "Datadog Integration Role"
  assume_role_policy = data.aws_iam_policy_document.assume_datadog[0].json

  role_policy_name     = "DatadogIntegrationPolicy"
  role_policy_document = data.aws_iam_policy_document.datadog_integration_aws[0].json
}

data "aws_iam_policy_document" "assume_datadog" {
  count = var.deploy ? 1 : 0
  statement {
    sid     = "DatadogAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = ["${var.datadog_aws_account_id}"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "sts:ExternalId"
      values   = ["${datadog_integration_aws.account[0].external_id}"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "datadog_integration_aws" {
  count = var.deploy ? 1 : 0
  statement {
    sid    = "DatadogIntegration"
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "autoscaling:Describe*",
      "backup:List*",
      "budgets:ViewBudget",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codedeploy:List*",
      "codedeploy:BatchGet*",
      "directconnect:Describe*",
      "dynamodb:List*",
      "dynamodb:Describe*",
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:List*",
      "elasticmapreduce:Describe*",
      "es:ListTags",
      "es:ListDomainNames",
      "es:DescribeElasticsearchDomains",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "health:DescribeEvents",
      "health:DescribeEventDetails",
      "health:DescribeAffectedEntities",
      "kinesis:List*",
      "kinesis:Describe*",
      "lambda:GetPolicy",
      "lambda:List*",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "organizations:Describe*",
      "organizations:List*",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "s3:GetBucketLogging",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "ses:Get*",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "states:ListStateMachines",
      "states:DescribeStateMachine",
      "support:DescribeTrustedAdvisor*",
      "support:RefreshTrustedAdvisorCheck",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries"
    ]
    resources = [
      "*"
    ]
  }
}

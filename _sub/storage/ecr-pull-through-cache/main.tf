/* --------------------------------------------------
Authentication (if required) for ECR pull-through cache
-------------------------------------------------- */

# trunk-ignore(checkov/CKV2_AWS_57)
# trunk-ignore(checkov/CKV_AWS_149)
resource "aws_secretsmanager_secret" "this" {
  count                   = var.username != "" && var.token != "" ? 1 : 0
  name                    = var.secret_name
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "this" {
  count     = var.username != "" && var.token != "" ? 1 : 0
  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    username    = var.username
    accessToken = var.token
  })
}


/* --------------------------------------------------
ECR repo template for cache
-------------------------------------------------- */

data "aws_ecr_lifecycle_policy_document" "this" {
  rule {
    priority    = 1
    description = "Expire old images"
    selection {
      tag_status   = "any"
      count_type   = "sinceImagePushed"
      count_number = var.cache_lifecycle_days
      count_unit   = "days"
    }
  }
}

resource "aws_ecr_repository_creation_template" "this" {
  prefix           = "ROOT"
  applied_for      = ["PULL_THROUGH_CACHE"]
  lifecycle_policy = data.aws_ecr_lifecycle_policy_document.this.json
}


/* --------------------------------------------------
ECR pull-through cache
-------------------------------------------------- */

resource "aws_ecr_pull_through_cache_rule" "authenticated" {
  count                 = var.username != "" && var.token != "" ? 1 : 0
  ecr_repository_prefix = var.ecr_repository_prefix
  upstream_registry_url = var.upstream_registry_url
  credential_arn        = aws_secretsmanager_secret.this[0].arn
}

resource "aws_ecr_pull_through_cache_rule" "anonymous" {
  count                 = var.username == "" && var.token == "" ? 1 : 0
  ecr_repository_prefix = var.ecr_repository_prefix
  upstream_registry_url = var.upstream_registry_url
  credential_arn        = aws_secretsmanager_secret.this[0].arn
}

locals {
  registry_id = aws_ecr_pull_through_cache_rule.authenticated[0].registry_id != "" ? aws_ecr_pull_through_cache_rule.authenticated[0].registry_id : aws_ecr_pull_through_cache_rule.anonymous[0].registry_id
}


/* --------------------------------------------------
ECR access policy (for entire registry)
-------------------------------------------------- */

data "aws_iam_policy_document" "this" {
  statement {
    sid = "PullThroughCache"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:BatchImportUpstreamImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${local.registry_id}:repository/${var.ecr_repository_prefix}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:PrincipalOrgID"
      test     = "StringLike"
      values   = [var.aws_org_id]
    }
  }
}

resource "aws_ecr_registry_policy" "this" {
  policy = data.aws_iam_policy_document.this.json
}



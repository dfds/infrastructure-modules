# --------------------------------------------------
# GitHub integration
# --------------------------------------------------

locals {
  deploy_name = "atlantis"
}

data "github_repository" "repo" {
  full_name = var.repository
}

resource "github_repository_webhook" "webhook" {
  repository = data.github_repository.repo.name

  configuration {
    url          = "https://${local.deploy_name}:${urlencode(var.dashboard_password)}@${var.ingress_hostname}/events"
    content_type = "application/json"
    secret       = var.webhook_secret
    insecure_ssl = false
  }

  events = var.webhook_events
}

resource "github_actions_organization_secret" "atlantis_username" {
  count                   = var.enable_github_secrets ? 1 : 0
  secret_name             = "${upper(var.environment)}_ATLANTIS_USERNAME"
  visibility              = "selected"
  plaintext_value         = local.deploy_name
  selected_repository_ids = data.github_repository.repo.repo_id
}

resource "github_actions_organization_secret" "atlantis_password" {
  count                   = var.enable_github_secrets ? 1 : 0
  secret_name             = "${upper(var.environment)}_ATLANTIS_PASSWORD"
  visibility              = "selected"
  plaintext_value         = var.dashboard_password
  selected_repository_ids = data.github_repository.repo.repo_id
}

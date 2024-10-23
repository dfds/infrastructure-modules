# --------------------------------------------------
# GitHub integration
# --------------------------------------------------

locals {
  deploy_name = "atlantis"
}

data "github_repository" "repo" {
  count     = length(var.github_repositories)
  full_name = var.github_repositories[count.index]
}

resource "github_repository_webhook" "webhook" {
  count      = length(data.github_repository.repo)
  repository = data.github_repository.repo[count.index].name

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
  selected_repository_ids = [for repo in data.github_repository.repo : repo.repo_id]
}

resource "github_actions_organization_secret" "atlantis_password" {
  count                   = var.enable_github_secrets ? 1 : 0
  secret_name             = "${upper(var.environment)}_ATLANTIS_PASSWORD"
  visibility              = "selected"
  plaintext_value         = var.dashboard_password
  selected_repository_ids = [for repo in data.github_repository.repo : repo.repo_id]
}

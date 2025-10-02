# --------------------------------------------------
# GitHub integration
# --------------------------------------------------

locals {
  deploy_name = "atlantis"
}

data "github_repository" "repo" {
  for_each  = toset(var.github_repositories)
  full_name = each.value
}

resource "github_repository_webhook" "webhook" {
  for_each   = data.github_repository.repo
  repository = each.value.name

  configuration {
    url          = "https://${local.deploy_name}:${urlencode(var.dashboard_password)}@${var.ingress_hostname}/events"
    content_type = "application/json"
    secret       = var.webhook_secret
    insecure_ssl = false
  }

  events = var.webhook_events
}

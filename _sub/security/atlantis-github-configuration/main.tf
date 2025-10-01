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

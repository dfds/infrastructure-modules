# --------------------------------------------------
# GitHub integration
# --------------------------------------------------

data "github_repository" "repo" {
  count     = length(var.github_repositories)
  full_name = var.github_repositories[count.index]
}

resource "random_password" "webhook" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

# TODO: Add support for multiple repositories
# resource "github_repository_webhook" "webhook" {
#   count      = length(data.github_repository.repo)
#   repository = data.github_repository.repo[count.index].name

#   configuration {
#     url          = "https://${local.deploy_name}:${urlencode(random_password.password.result)}@${var.ingress_hostname}/events"
#     content_type = "application/json"
#     secret       = random_password.webhook.result
#     insecure_ssl = false
#   }

#   events = var.webhook_events
# }

# resource "github_actions_organization_secret" "atlantis_username" {
#   count                   = var.github_enable_org_secrets ? 1 : 0
#   secret_name             = "${upper(var.environment)}_ATLANTIS_USERNAME"
#   visibility              = "selected"
#   plaintext_value         = local.deploy_name
#   selected_repository_ids = [for repo in data.github_repository.repo : repo.repo_id]
# }

# resource "github_actions_organization_secret" "atlantis_password" {
#   count                   = var.github_enable_org_secrets ? 1 : 0
#   secret_name             = "${upper(var.environment)}_ATLANTIS_PASSWORD"
#   visibility              = "selected"
#   plaintext_value         = random_password.password.result
#   selected_repository_ids = [for repo in data.github_repository.repo : repo.repo_id]
# }


# --------------------------------------------------
# Atlantis Dashboard credentials
# --------------------------------------------------

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "htpasswd_password" "hash" {
  password = random_password.password.result
  salt     = substr(sha512(random_password.password.result), 0, 8)
}

resource "aws_ssm_parameter" "dashboard_username" {
  name        = "/eks/${var.cluster_name}/${local.deploy_name}-username"
  description = "Username for accessing the Atlantis UI"
  type        = "SecureString"
  value       = local.deploy_name

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
}

resource "aws_ssm_parameter" "dashboard_password" {
  name        = "/eks/${var.cluster_name}/${local.deploy_name}-password"
  description = "Password for accessing the Atlantis UI"
  type        = "SecureString"
  value       = random_password.password.result

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
}

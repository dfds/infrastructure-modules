# --------------------------------------------------
# GitHub integration
# --------------------------------------------------

resource "random_password" "webhook" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

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

resource "aws_ssm_parameter" "webhook_secret" {
  name        = "/eks/${var.cluster_name}/${local.deploy_name}-webhook-secret"
  description = "Secret for mutual trust between Atlantis and GitHub"
  type        = "SecureString"
  value       = random_password.webhook.result

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
}

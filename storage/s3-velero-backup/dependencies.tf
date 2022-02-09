locals {
  oidc_provider_arn = "arn:aws:iam::${var.oidc_provider_account_id}:oidc-provider/${var.oidc_provider_server_id}"
}

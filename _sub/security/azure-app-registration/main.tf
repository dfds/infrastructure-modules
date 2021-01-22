locals {
  SIGN_IN_AND_READ_USER_PROFILE = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
}

# --------------------------------------------------
# Grant AAD access True
# --------------------------------------------------
resource "azuread_application" "aad_access" {
  count           = var.deploy && var.grant_aad_access ? 1 : 0
  display_name    = var.name
  homepage        = var.homepage
  identifier_uris = var.identifier_uris
  reply_urls      = var.reply_urls

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id   = local.SIGN_IN_AND_READ_USER_PROFILE
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "aad_access" {
  count = var.deploy && var.grant_aad_access ? 1 : 0
  application_id = element(
    concat(
      azuread_application.aad_access.*.application_id,
      ["00000000-0000-0000-0000-000000000000"],
    ),
    0,
  )
}

resource "null_resource" "aad_access_appreg_key" {
  count = var.deploy && var.grant_aad_access ? 1 : 0

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/create_key.sh ${element(
      concat(
        azuread_application.aad_access.*.application_id,
        ["00000000-1337-0000-0000-000000000000"],
      ),
      0,
    )} s3://${var.appreg_key_bucket}/${var.appreg_key_key}"
  }
}

data "external" "aad_access_appreg_key" {
  count      = var.deploy && var.grant_aad_access ? 1 : 0
  depends_on = [null_resource.aad_access_appreg_key]
  program    = ["sh", "${path.module}/read_key.sh"]

  query = {
    key_path_s3 = "s3://${var.appreg_key_bucket}/${var.appreg_key_key}"
  }
}

# --------------------------------------------------
# Grant AAD access False
# --------------------------------------------------

resource "azuread_application" "no_aad_access" {
  count           = var.deploy && false == var.grant_aad_access ? 1 : 0
  display_name    = var.name
  homepage        = var.homepage
  identifier_uris = var.identifier_uris
  reply_urls      = var.reply_urls
}

resource "azuread_service_principal" "no_aad_access" {
  count = var.deploy && false == var.grant_aad_access ? 1 : 0
  application_id = element(
    concat(
      azuread_application.no_aad_access.*.application_id,
      ["00000000-0000-0000-0000-000000000000"],
    ),
    0,
  )
}

resource "null_resource" "no_aad_access_appreg_key" {
  count = var.deploy && false == var.grant_aad_access ? 1 : 0

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/create_key.sh ${element(
      concat(
        azuread_application.no_aad_access.*.application_id,
        ["00000000-0000-1337-0000-000000000000"],
      ),
      0,
    )} s3://${var.appreg_key_bucket}/${var.appreg_key_key}"
  }
}

data "external" "no_aad_access_appreg_key" {
  count      = var.deploy && false == var.grant_aad_access ? 1 : 0
  depends_on = [null_resource.no_aad_access_appreg_key]
  program    = ["sh", "${path.module}/read_key.sh"]

  query = {
    key_path_s3 = "s3://${var.appreg_key_bucket}/${var.appreg_key_key}"
  }
}

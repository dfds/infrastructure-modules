resource "azuread_application" "app" {
  count           = "${var.deploy}"
  name            = "${var.name}"
  homepage        = "${var.homepage}"
  identifier_uris = "${var.identifier_uris}"
  reply_urls      = "${var.reply_urls}"
}

resource "azuread_service_principal" "app" {
  count          = "${var.deploy}"
  application_id = "${azuread_application.app.application_id}"
}

resource "null_resource" "new_appreg_key" {
  count = "${var.deploy}"

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/create_key.sh ${azuread_application.app.application_id} s3://${var.appreg_key_bucket}/${var.appreg_key_key}"
  }
}

data "external" "appreg_key" {
  count      = "${var.deploy}"
  depends_on = ["null_resource.new_appreg_key"]
  program    = ["sh", "${path.module}/read_key.sh"]

  query = {
    key_path_s3 = "s3://${var.appreg_key_bucket}/${var.appreg_key_key}"
  }
}
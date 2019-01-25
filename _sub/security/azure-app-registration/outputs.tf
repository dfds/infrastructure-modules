output "application_id" {
  value = "${azuread_application.app.application_id}"
}

output "application_key" {
  sensitive = true
  value = "${data.external.appreg_key.result["password"]}"
}

output "tenant_id" {
  sensitive = true
  value = "${data.external.appreg_key.result["tenant"]}"
}
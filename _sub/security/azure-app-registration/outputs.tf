locals {
  # Output from data.external is a map in a single-item list.
  # All attempts so far to resolve this in one-line has been fruitless,
  # hence using local variables for intermediate steps.
  # E.g. element() only works with simple lists consisting of strings, not maps.
  # and the [0] notion didn't seem to work when appended to the concact() function.

  # Append a list item with a map containing the null-valued keys we need to extract.
  # If result is empty, the list will have a single element containing the null-valued keys.
  # If not empty, the first element will be the actual result, followed by the nullvalued keys.
  result_list = "${concat(concat(data.external.aad_access_appreg_key.*.result, data.external.no_aad_access_appreg_key.*.result), list(map("password", "", "tenant", "")))}"
}

output "application_id" {
  # Default value set to "00000000-0000-0000-0000-000000000000" to avoid:
  # InvalidLoadBalancerAction: The 'client id' field must be between 1 and 1024 characters in length
  # when count is zero.
  value = "${var.grant_aad_access ? "${element(concat(azuread_application.aad_access.*.application_id, list("00000000-0000-0000-0000-000000000000")), 0)}" : "${element(concat(azuread_application.no_aad_access.*.application_id, list("00000000-0000-0000-0000-000000000000")), 0)}"}"
}

output "application_key" {
  # In the first element of the result_list, lookup the value of the "password" key
  value     = "${lookup(local.result_list[0], "password", "")}"
  sensitive = true
}

output "tenant_id" {
  # In the first element of the result_list, lookup the value of the "tenant" key
  value     = "${lookup(local.result_list[0], "tenant", "")}"
  sensitive = true
}
 
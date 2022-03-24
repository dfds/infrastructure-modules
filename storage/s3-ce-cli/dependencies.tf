data "template_file" "iam_inventory_role_policy" {
  template = file("${path.module}/json/iam_inventory_role_policy.json")
  vars = {
    bucket_name = "mybucket"
  }
}

data "template_file" "iam_inventory_role_trust" {
  template = file("${path.module}/json/iam_inventory_role_trust.json")
  vars = {
    billing_account_id = "999999999999"
  }
}
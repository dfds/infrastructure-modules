resource "aws_organizations_account" "org_account" {
  name                       = "${lower(var.name)}"
  email                      = "${var.email}"
  iam_user_access_to_billing = "ALLOW"
  role_name                  = "${var.org_role_name}"

  provisioner "local-exec" {
    command = "sleep ${var.sleep_after}"
  }
}

# Move AWS account to specified OU - should be replaced once supported and verified by AWS Terraform provider
resource "null_resource" "move_account" {
  # Only apply if both source and destination ID is specified
  count = "${length(var.parent_id) > 0 && length(var.master_account_id) > 0 && length(var.prime_role_name) > 0 ? 1 : 0}"

  depends_on = [
    "aws_organizations_account.org_account",
  ]

  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/move_account.sh ${aws_organizations_account.org_account.id} ${var.parent_id} arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

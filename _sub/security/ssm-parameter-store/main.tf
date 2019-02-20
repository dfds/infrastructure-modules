resource "aws_ssm_parameter" "putSecureString" {
  name        = "${var.key_name}"
  description = "${var.key_description}"
  type        = "SecureString"
  value       = "${var.key_value}"
  overwrite   = true
}
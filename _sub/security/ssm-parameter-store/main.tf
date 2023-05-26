resource "aws_ssm_parameter" "putSecureString" {
  count       = var.deploy ? 1 : 0
  name        = var.key_name
  description = var.key_description
  type        = "SecureString"
  value       = var.key_value
  tags = {
    createdBy = var.tag_createdby != null ? var.tag_createdby : "ssm-parameter-store"
  }
}

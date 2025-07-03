resource "aws_ssm_parameter" "putSecureString" {
  #checkov:skip=CKV_AWS_337: Ensure SSM parameters are using KMS CMK
  count       = var.deploy ? 1 : 0
  name        = var.key_name
  description = var.key_description
  type        = "SecureString"
  value       = var.key_value
  tags = merge(
    var.tags,
    {
      createdBy = var.tag_createdby != null ? var.tag_createdby : "ssm-parameter-store"
    }
  )
  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
}

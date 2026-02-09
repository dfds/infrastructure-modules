resource "aws_cloudformation_stack_set" "azure_defender" {
  name = "azure-defender"

  auto_deployment {
    enabled = true
  }

  template_body = templatefile("${path.module}/template.json", {
    aad_tenant_id = local.aad_tenant_id
    oidc_client_id = var.oidc_client_id
    client_tenant = var.client_tenant
    oidc_thumbprint_list = jsonencode(var.oidc_thumbprint_list)
  })

  permission_model = "SERVICE_MANAGED"
  call_as          = "DELEGATED_ADMIN"

}

resource "aws_cloudformation_stack_set_instance" "azure_defender" {
  stack_set_name = aws_cloudformation_stack_set.azure_defender.name
  call_as = "DELEGATED_ADMIN"
    deployment_targets {
        organizational_unit_ids = local.organizational_unit_ids
        }
}

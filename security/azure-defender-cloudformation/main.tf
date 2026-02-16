locals {
  aad_tenant_id = "33e01921-4d64-4f8c-a055-5bdaffd5e33d"
}

resource "aws_cloudformation_stack_set" "azure_defender" {
  name = "azure-defender"

  auto_deployment {
    enabled = true
  }

  template_body = templatefile("${path.module}/template.json", {
    aad_tenant_id        = local.aad_tenant_id
    oidc_client_id       = var.oidc_client_id
    client_tenant        = var.client_tenant
    oidc_thumbprint_list = jsonencode(var.oidc_thumbprint_list)
  })

  permission_model = "SERVICE_MANAGED"
  call_as          = "DELEGATED_ADMIN"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  managed_execution {
    active = true
  }
}

resource "aws_cloudformation_stack_set_instance" "azure_defender" {
  for_each = { for ou in var.ous : ou.ou_id => ou }

  stack_set_name = aws_cloudformation_stack_set.azure_defender.name
  call_as        = "DELEGATED_ADMIN"
  deployment_targets {
    organizational_unit_ids = [each.value.ou_id]
    account_filter_type     = each.value.account_filter_type
    accounts                = length(each.value.accounts) == 0 ? null : each.value.accounts
  }

  operation_preferences {
    failure_tolerance_count   = 0
    max_concurrent_percentage = 25
    concurrency_mode          = "SOFT_FAILURE_TOLERANCE"
    region_concurrency_type   = "SEQUENTIAL"
  }
}

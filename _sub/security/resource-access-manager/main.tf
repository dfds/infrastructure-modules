locals {
  all_tags = merge(var.tags, { "Name" = var.resource_share_name })
}

resource "aws_ram_resource_share" "this" {
  name                      = var.resource_share_name
  allow_external_principals = false // Allow only accounts within the organization to access the resource share
  tags                      = local.all_tags
}

resource "aws_ram_resource_association" "this" {
  for_each           = { for idx, arn in var.resource_arns : idx => arn }
  resource_share_arn = aws_ram_resource_share.this.arn
  resource_arn       = each.value
}

resource "aws_ram_principal_association" "this" {
  for_each           = toset(var.principals)
  resource_share_arn = aws_ram_resource_share.this.arn
  principal          = each.value
}

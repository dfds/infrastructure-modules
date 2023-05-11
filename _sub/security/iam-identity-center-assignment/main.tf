data "aws_ssoadmin_instances" "dfds" {}

data "aws_ssoadmin_permission_set" "permission_set" {
  instance_arn = tolist(data.aws_ssoadmin_instances.dfds.arns)[0]
  name         = var.permission_set_name
}

data "aws_identitystore_group" "group" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.dfds.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.group_name
    }
  }
}

resource "aws_ssoadmin_account_assignment" "assignment" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.dfds.arns)[0]
  permission_set_arn = data.aws_ssoadmin_permission_set.permission_set.arn

  principal_id   = data.aws_identitystore_group.group.group_id
  principal_type = "GROUP"

  target_id   = var.aws_account_id
  target_type = "AWS_ACCOUNT"
}
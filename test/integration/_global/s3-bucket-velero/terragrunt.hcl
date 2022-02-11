terraform {
  source = "../../../..//storage/s3-velero-backup"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../../eu-west-1/k8s-qa21/services"]
}

inputs = {
  bucket_name = "dfds-velero-qa"
  oidc_provider_account_id = "266901158286"
  # Dummy oidc_provider_server_id, because it can not be calculated at runtime due to race condition
  oidc_provider_server_id = "oidc.eks.eu-west-1.amazonaws.com/id/00000000000000000000000000000000"
}

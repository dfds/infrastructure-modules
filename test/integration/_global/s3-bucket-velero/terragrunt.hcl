terraform {
  source = "../../../..//storage/s3-velero-backup"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders("root.hcl")}"
}

dependencies {
  paths = ["../../eu-west-1/k8s-qa/services"]
}

inputs = {
  bucket_name      = "dfds-velero-qa"
}

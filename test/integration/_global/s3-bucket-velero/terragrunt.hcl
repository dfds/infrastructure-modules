terraform {
  source = "../../../..//storage/s3-velero-backup"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../../eu-west-1/k8s-qa20/services"]
}

inputs = {
  bucket_name = "dfds-velero-qa"
  kiam_server_role_arn = ["arn:aws:iam::266901158286:role/eks-qa20-kiam-server"]
}

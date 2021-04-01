terraform {
  source = "../../../..//storage/s3-velero-backup"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

inputs = {
  bucket_name = "dfds-velero"
  kiam_server_role_arn = "arn:aws:iam::266901158286:role/eks-*-kiam-server"
}

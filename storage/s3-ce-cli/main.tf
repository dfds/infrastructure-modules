module "bucket" {
  source          = "../../_sub/storage/s3-bucket"
  s3_bucket       = var.bucket_name
  additional_tags = var.additional_tags
}

module "iam_inventory_role_policy" {
  source  = "../../_sub/storage/s3-bucket-object"
  bucket  = module.bucket.bucket_name
  key     = "aws/iam/inventory-role/policy.json"
  content = data.aws_iam_policy_document.iam_inventory_role_policy.json
}

module "iam_inventory_role_trust" {
  source  = "../../_sub/storage/s3-bucket-object"
  bucket  = module.bucket.bucket_name
  key     = "aws/iam/inventory-role/trust.json"
  content = data.aws_iam_policy_document.iam_inventory_role_trust.json
}

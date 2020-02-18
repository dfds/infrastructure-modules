resource "aws_cloudtrail" "cloudtrail" {
  count                         = var.deploy ? 1 : 0
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_trail
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true
}

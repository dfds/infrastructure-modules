# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.12.2"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.21.0"  # from 2.11 Minimum required 2.14

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

# --------------------------------------------------
# Cloudfront distribution setup
# --------------------------------------------------

module "aws_cf_oai" {
  source       = "../../_sub/cdn/cloudfront_oai"
  comment = "${var.cf_dist_comment} user for accessing s3 buckets"
}


module "aws_cf_dist" {
  source       = "../../_sub/cdn/cloudfront_dist"
  origins = var.cf_dist_origins
  cache_behaviors = var.cf_dist_cache_behaviors
  acm_certificate_arn = "${var.cf_dist_domain_certificate_arn}"
  comment = var.cf_dist_comment
  aliases = "${length(var.cf_dist_domain_name) == 0 ? [] : [var.cf_dist_domain_name]}"
  # lambda_edge_qualified_arn = "${var.deploy_lambda_edge_func ? module.aws_cf_dist_default_behavior_lambda_function.lambda_function_qualified_arn : null }"
   # FIXME: It's not enough to remove the association. You need to wait for at least 30 minutes before AWS removes all replicas of the lambda@edge function. See: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html
   # TODO: A local exec function that listen to 
  origin_access_identity = "${module.aws_cf_oai.origin_access_identity}"
  logging_enable = "${var.cf_dist_logging_enable}"  
  logging_include_cookies= "${var.cf_dist_logging_include_cookies}"
  logging_bucket = "${var.cf_dist_logging_bucket}"
  logging_prefix = "${var.cf_dist_logging_prefix}"
}
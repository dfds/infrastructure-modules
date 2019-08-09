# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.12.2"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.15"  # from 2.11 Minimum required 2.14

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  region  = var.aws_acm_region
  version = "~> 2.15"  # from 2.11 Minimum required 2.14
  alias  = "acm"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "aws_route53_cf_record" { # As of now, AWS Terraform providor does not have a data source for aws_cloudfront_distribution
  source = "../cf-route53-records"
  aws_region = "${var.aws_region}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  cf_route53_records_deploy = "${var.cf_route53_records_deploy}"
  cf_dns_zone = "${var.cf_dns_zone}"
  cf_distribution_hosted_zone_id = "${module.aws_cloudfront.distribution_hosted_zone_id}"
  cf_distribution_domain_name = "${module.aws_cloudfront.distribution_domain_name}"
  cf_distribution_domain_name = "${module.aws_cloudfront.distribution_domain_name}"
}


module "aws_cf_oai" {
  source       = "../../../_sub/cdn/cloudfront_oai"
  comment = "${var.cdn_comment} Canonical user id used for s3 buckets"
}

module "aws_cloudfront" {
  source       = "../../_sub/cdn/cloudfront"
  cdn_origins = var.cdn_origins
  cdn_comment = var.cdn_comment  
  
  # aliases = "${var.cdn_domain_name == "" ? [] : [var.cdn_domain_name]}"
  origin_access_identity = "${module.aws_cf_oai.origin_access_identity}"
}

module "aws_cloudfront" { # redirect to www via API gateway
  source       = "../../../_sub/cdn/cloudfront"
  cdn_origins = var.cdn_origins
  cdn_comment = var.cdn_comment
  acm_certificate_arn = "${length(var.acm_certificate_arn) == 0 ? data.aws_acm_certificate.cf_domain_cert.arn : var.acm_certificate_arn}"
  aliases = ["${var.cf_dns_zone}"]
}


# TODO: Default behavior lambda@edge function. HOWTO: https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#lambda_function_association
# # Lambda and API-gateway to enable manipulating http request
# module "aws_cf_dist_default_behavior_lambda_function" { # must be attached to default behavior
#   source = "../../../_sub/compute/lambda"
#   lambda_function_name = "-cdn"
#   lambda_role_name = "main-cdn-api-root-redirect"
#   lambda_function_handler = "lambda-root-redirect" # filename without fileextension 
#   lambda_env_variables =  {SITE_DOMAIN = "${var.cf_main_dns_zone}"}
#   aws_region = "${var.aws_region}"
#   s3_bucket = "${module.s3_bucket.bucket_name}"
#   s3_key = "${module.s3_object_upload.s3_object_key}"
# }

# # TODO: should be produced via CD pipeline
# module "s3_object_upload" { 
#   source = "../../../_sub/misc/s3-bucket-object"
#   s3_bucket = "${module.s3_bucket.bucket_name}"
#   key = "${var.lambda_zip_filepath}"
#   filepath = "${var.lambda_zip_filepath}"
# }

# # Bucket for lambda function
# module "s3_bucket" { 
#   source = "../../../_sub/storage/s3-bucket"
#   deploy = 1
#   s3_bucket = "${var.cf_lambda_s3bucket}"
# }

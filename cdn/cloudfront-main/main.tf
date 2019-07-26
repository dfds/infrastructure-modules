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

module "aws_route53_cf_redirect_record" {
  source = "../../_sub/network/route53-alias-record"
  # A record for dfds-ex.com
  deploy = "${var.cf_main_hosted_zone_deploy}"
  zone_id = "${module.route53_hosted_zone.dns_zone_id}"
  record_name = "${var.cf_main_dns_zone}"
  record_type = "A"
  alias_target_dns_name = "${module.aws_cloudfront_redirect.distribution_domain_name}"
  alias_target_zone_id = "${module.aws_cloudfront_redirect.distribution_hosted_zone_id}"
}

module "aws_route53_cf_www_record" {
  source = "../../_sub/network/route53-record"
  # CName record for www
  deploy = "${var.cf_main_hosted_zone_deploy}"
  zone_id = "${module.route53_hosted_zone.dns_zone_id}"
  record_name = "www.${var.cf_main_dns_zone}"
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.aws_cloudfront_www.distribution_domain_name}"  
}

# ------------------prereqs for route53records----------------------------------------#

module "aws_cloudfront_redirect" {
  source       = "../../_sub/cdn/cloudfront"
  cdn_origins = local.redirect_origin
  acm_certificate_arn = var.acm_certificate_arn  
  cdn_comment = "Root redirect for ${var.cdn_comment}"
  aliases = ["${var.cdn_domain_name}"] # ## via local or cdn_domain_name ??
}

module "aws_cloudfront_www" {
  source       = "../../_sub/cdn/cloudfront"
  cdn_origins = var.cdn_origins
  acm_certificate_arn = var.acm_certificate_arn  
  cdn_comment = var.cdn_comment
  aliases = ["www.${var.cdn_domain_name}"] 
}

# ------------------prereqs for cf + route53records----------------------------------------#
module "cf_domain_cert" {
  source        = "../../_sub/network/acm-certificate-san-simple"
  deploy        = "${var.cf_main_hosted_zone_deploy}" #"${var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy ? 1 : 0}"
  domain_name   = ["www.${var.cdn_domain_name}"] 
  dns_zone_name = "*.${module.route53_hosted_zone.dns_zone_name}"
  subject_alternative_names    = ["${var.cdn_domain_name}"]  
}

module "route53_hosted_zone" {
  source = "../../_sub/network/route53-zone"  
  deploy = "${var.cf_main_hosted_zone_deploy}"
  dns_zone_name = "${var.cf_main_dns_zone}"
}
# ---------------------------------------------------------#

# TODO: enable staging for api gateway 
module "aws_api_gateway" {
  source       = "../../_sub/network/api-gateway-lambda"
  api_gateway_rest_api_name = "main-cdn-api"
  lambda_function_invoke_arn = "${module.aws_lambda_function.lambda_function_invoke_arn}"
  lambda_function_name = "${module.aws_lambda_function.lambda_function_name}"  
}

# Lambda and API-gateway to enable manipulating http request
module "aws_lambda_function" {
  source = "../../_sub/compute/lambda"
  lambda_function_name = "main-cdn-api-root-redirect"
  lambda_role_name = "main-cdn-api-root-redirect"
  lambda_function_handler = "lambda-root-redirect" # filename without fileextension 
  lambda_env_variables =  {SITE_DOMAIN = "${var.cdn_domain_name}"}

  s3_bucket = "${module.s3_bucket.bucket_name}"
  s3_key = "${module.s3_object_upload.s3_object_key}"
}

# TODO: should be produced via CD pipeline
module "s3_object_upload" { 
  source = "../../_sub/misc/s3-bucket-object"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  key = "${var.lambda_zip_filepath}"
  filepath = "${var.lambda_zip_filepath}"
}

# Bucket for lambda function
module "s3_bucket" { 
  source = "../../_sub/storage/s3-bucket"
  deploy = 1
  s3_bucket = "${var.cf_lambda_s3bucket}"
}

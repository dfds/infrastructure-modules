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

# provider "aws" {
#   region  = var.aws_acm_region
#   version = "~> 2.15"  # from 2.11 Minimum required 2.14
#   alias  = "acm"

#   assume_role {
#     role_arn = var.aws_assume_role_arn
#   }
# }

# provider "aws" {
#   region  = var.aws_lambda_edge_region
#   version = "~> 2.15"  # from 2.11 Minimum required 2.14
#   alias  = "lambda"

#   assume_role {
#     role_arn = var.aws_assume_role_arn
#   }
# }

module "aws_route53_cf_redirect_record" { # As of now, AWS Terraform providor does not have a data source for aws_cloudfront_distribution
  source = "../cf-route53-records"
  aws_region = "${var.aws_region}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  cf_route53_records_deploy = "${var.cf_route53_records_deploy}"  
  cf_main_dns_zone = "${var.cf_main_dns_zone}"
  cf_redirect_distribution_hosted_zone_id = "${module.aws_cloudfront_redirect.distribution_hosted_zone_id}"
  cf_redirect_distribution_domain_name = "${module.aws_cloudfront_redirect.distribution_domain_name}"
  cf_www_distribution_domain_name = "${module.aws_cloudfront_www.distribution_domain_name}"
}


# # ------------------prereqs for route53records----------------------------------------#

module "aws_cloudfront_redirect" { # redirect to www via API gateway
  source       = "../../../_sub/cdn/cloudfront"
  cdn_origins = local.redirect_origin
  acm_certificate_arn = "${length(var.acm_certificate_arn) == 0 ? data.aws_acm_certificate.cf_domain_cert.arn : var.acm_certificate_arn}"
  cdn_comment = "Root redirect for ${var.cdn_comment}"
  aliases = ["${var.cf_main_dns_zone}"]
}

module "aws_cloudfront_www" {
  source       = "../../../_sub/cdn/cloudfront"
  cdn_origins = var.cdn_origins
  acm_certificate_arn = "${length(var.acm_certificate_arn) == 0 ? data.aws_acm_certificate.cf_domain_cert.arn : var.acm_certificate_arn}"
  cdn_comment = var.cdn_comment
  aliases = ["www.${var.cf_main_dns_zone}"]
  lambda_edge_qualified_arn = "${module.aws_cf_dist_default_behavior_lambda_function.lambda_function_qualified_arn}"
}

# ------------------prereqs for cf + route53records----------------------------------------# Can be created separatly 


# ---------------------------------------------------------#

# TODO: enable staging for api gateway 
module "aws_api_gateway" {
  source       = "../../../_sub/network/api-gateway-lambda"
  api_gateway_rest_api_name = "main-cdn-api"
  lambda_function_invoke_arn = "${module.aws_api_gateway_lambda_function.lambda_function_invoke_arn}"
  lambda_function_name = "${module.aws_api_gateway_lambda_function.lambda_function_name}"    
}

# Lambda and API-gateway to enable manipulating http request
module "aws_api_gateway_lambda_function" {
  source = "../../../_sub/compute/lambda"
  lambda_function_name = "main-cdn-api-root-redirect" #TODO; need propper prefix 
  lambda_role_name = "main-cdn-api-root-redirect-test" #TODO; need propper prefix 
  lambda_function_handler = "lambda-root-redirect" # filename without fileextension 
  lambda_env_variables =  {SITE_DOMAIN = "${var.cf_main_dns_zone}"}
  aws_region = "${var.aws_region}"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  s3_key = "${module.s3_object_upload_api_lambda.s3_object_key}"
}

# Lambda@funtion to manipulating http request
module "aws_cf_dist_default_behavior_lambda_function" { # must be attached to default behavior
  source = "../../../_sub/compute/lambda"
  lambda_function_name = "main-cdn-default-redirect-rules" #TODO; need propper prefix 
  lambda_role_name = "main-cdn-default-redirect-rules-test" #TODO; need propper prefix 
  lambda_function_handler = "lambda-redirect-rules" # filename without fileextension 
  # lambda_env_variables =  {SITE_DOMAIN = "${var.cf_main_dns_zone}"}
  aws_region = "${var.aws_region}"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  s3_key = "${module.s3_object_upload_lambda_edge.s3_object_key}"
  publish = true

  providers = {
    aws = "aws.lambda"
  }  
}

# TODO: should be produced via CD pipeline
module "s3_object_upload_lambda_edge" { 
  source = "../../../_sub/misc/s3-bucket-object"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  key = "${var.lambda_edge_zip_filepath}"
  filepath = "${var.lambda_edge_zip_filepath}"
}

# TODO: should be produced via CD pipeline
module "s3_object_upload_api_lambda" { 
  source = "../../../_sub/misc/s3-bucket-object"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  key = "${var.lambda_zip_filepath}"
  filepath = "${var.lambda_zip_filepath}"
}


# Bucket for lambda function
module "s3_bucket" { 
  source = "../../../_sub/storage/s3-bucket"
  deploy = 1
  s3_bucket = "${var.cf_lambda_s3bucket}"
}
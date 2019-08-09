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


## TODO: put into own folder
module "aws_route53_cf_redirect_record" {
  source = "../../_sub/network/route53-alias-record"
  # A record for dfds-ex.com
  deploy = "${var.cf_route53_records_deploy}"
  zone_id = "${var.cf_main_hosted_zone_deploy ? module.route53_hosted_zone.dns_zone_id: data.aws_route53_zone.zone[0].id}"
  record_name = ["${var.cf_main_dns_zone}"]
  record_type = "A"
  alias_target_dns_name = "${module.aws_cloudfront_redirect.distribution_domain_name}"
  alias_target_zone_id = "${module.aws_cloudfront_redirect.distribution_hosted_zone_id}"
}

module "aws_route53_cf_www_record" {
  source = "../../_sub/network/route53-record"
  # CName record for www
  deploy = "${var.cf_route53_records_deploy}"
  zone_id = "${var.cf_main_hosted_zone_deploy ? module.route53_hosted_zone.dns_zone_id: data.aws_route53_zone.zone[0].id}"
  record_name = ["www.${var.cf_main_dns_zone}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.aws_cloudfront_www.distribution_domain_name}"  
}

# # ------------------prereqs for route53records----------------------------------------#

module "aws_cloudfront_redirect" {
  source       = "../../_sub/cdn/cloudfront_dist"
  origins = local.redirect_origin
  # acm_certificate_arn = "${module.cf_domain_cert.certificate_arn}" #var.acm_certificate_arn  
  acm_certificate_arn = "${var.cf_domain_cert_deploy ? module.cf_domain_cert.certificate_arn: data.aws_acm_certificate.cf_domain_cert[0].arn}"
  # TODO: make it possible to get certificate arn from variable 
  comment = "Root redirect for ${var.cdn_comment}"
  aliases = ["${var.cf_main_dns_zone}"]  # ["${var.cdn_domain_name}"] # via local or cdn_domain_name ??
}

module "aws_cloudfront_www" {
  source       = "../../_sub/cdn/cloudfront_dist"
  origins = var.cdn_origins
  # acm_certificate_arn = "${module.cf_domain_cert.certificate_arn}" #var.acm_certificate_arn  
  acm_certificate_arn = "${var.cf_domain_cert_deploy ? module.cf_domain_cert.certificate_arn: data.aws_acm_certificate.cf_domain_cert[0].arn}"
  # TODO: make it possible to get certificate arn from variable 
  comment = var.cdn_comment
  aliases = ["www.${var.cf_main_dns_zone}"]  # ["www.${var.cdn_domain_name}"]
  lambda_edge_qualified_arn = "${module.aws_cf_dist_default_behavior_lambda_function.lambda_function_qualified_arn}"
}

# ------------------prereqs for cf + route53records----------------------------------------# Can be created separatly 
module "cf_domain_cert" {
  source        = "../../_sub/network/acm-certificate-san-simple"
  deploy        = "${var.cf_domain_cert_deploy}" #"${var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy ? 1 : 0}"
  domain_name   = "www.${var.cf_main_dns_zone}" #"www.${var.cdn_domain_name}"
  # dns_zone_name = "*.${module.route53_hosted_zone.dns_zone_name}"
  dns_zone_id = "${var.cf_main_hosted_zone_deploy ? module.route53_hosted_zone.dns_zone_id: data.aws_route53_zone.zone[0].id}"
  # TODO: make it possible to get zoneid from variable 

  subject_alternative_names    = ["${var.cf_main_dns_zone}"] #["${var.cdn_domain_name}"]  
}

module "route53_hosted_zone" {
  source = "../../_sub/network/route53-zone"  
  deploy = "${var.cf_main_hosted_zone_deploy}"
  dns_zone_name = "${var.cf_main_dns_zone}"
}



# ---------------------------------------------------------#

# # TODO: enable staging for api gateway 
# module "aws_api_gateway" {
#   source       = "../../_sub/network/api-gateway-lambda"
#   api_gateway_rest_api_name = "main-cdn-api"
#   lambda_function_invoke_arn = "${module.aws_lambda_function.lambda_function_invoke_arn}"
#   lambda_function_name = "${module.aws_lambda_function.lambda_function_name}"  
# }

# # Lambda and API-gateway to enable manipulating http request
# module "aws_lambda_function" {
#   source = "../../_sub/compute/lambda"
#   lambda_function_name = "main-cdn-api-root-redirect"
#   lambda_role_name = "main-cdn-api-root-redirect"
#   lambda_function_handler = "lambda-root-redirect" # filename without fileextension 
#   lambda_env_variables =  {SITE_DOMAIN = "${var.cdn_domain_name}"}

#   s3_bucket = "${module.s3_bucket.bucket_name}"
#   s3_key = "${module.s3_object_upload.s3_object_key}"
# }

# # TODO: should be produced via CD pipeline
# module "s3_object_upload" { 
#   source = "../../_sub/misc/s3-bucket-object"
#   s3_bucket = "${module.s3_bucket.bucket_name}"
#   key = "${var.lambda_zip_filepath}"
#   filepath = "${var.lambda_zip_filepath}"
# }

# # Bucket for lambda function
# module "s3_bucket" { 
#   source = "../../_sub/storage/s3-bucket"
#   deploy = 1
#   s3_bucket = "${var.cf_lambda_s3bucket}"
# }


# ---------------------------------------------------------#

# TODO: enable staging for api gateway 
module "aws_api_gateway" {
  source       = "../../_sub/network/api-gateway-lambda"
  api_gateway_rest_api_name = "main-cdn-api"
  lambda_function_invoke_arn = "${module.aws_api_gateway_lambda_function.lambda_function_invoke_arn}"
  lambda_function_name = "${module.aws_api_gateway_lambda_function.lambda_function_name}"    
}

# Lambda and API-gateway to enable manipulating http request
module "aws_api_gateway_lambda_function" {
  source = "../../_sub/compute/lambda"
  lambda_function_name = "main-cdn-api-root-redirect" #TODO; need propper prefix 
  lambda_role_name = "main-cdn-api-root-redirect" #TODO; need propper prefix 
  lambda_function_handler = "lambda-root-redirect" # filename without fileextension 
  lambda_env_variables =  {SITE_DOMAIN = "${var.cf_main_dns_zone}"}
  aws_region = "${var.aws_region}"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  s3_key = "${module.s3_object_upload_api_lambda.s3_object_key}"
}

# Lambda@funtion to manipulating http request
module "aws_cf_dist_default_behavior_lambda_function" { # must be attached to default behavior
  source = "../../_sub/compute/lambda-edge"
  lambda_function_name = "main-cdn-default-redirect-rules" #TODO; need propper prefix 
  lambda_role_name = "main-cdn-default-redirect-rules" #TODO; need propper prefix 
  lambda_function_handler = "lambda-redirect-rules" # filename without fileextension 
  # lambda_env_variables =  {SITE_DOMAIN = "${var.cf_main_dns_zone}"}
  aws_region = "${var.aws_region}"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  s3_key = "${module.s3_object_upload_lambda_edge.s3_object_key}"
  publish = true

}

# TODO: should be produced via CD pipeline
module "s3_object_upload_lambda_edge" { 
  source = "../../_sub/misc/s3-bucket-object"
  s3_bucket = "${module.s3_bucket.bucket_name}"
  key = "${var.lambda_edge_zip_filepath}"
  filepath = "${var.lambda_edge_zip_filepath}"
}

# TODO: should be produced via CD pipeline
module "s3_object_upload_api_lambda" { 
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
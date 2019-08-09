# --------------------------------------------------
# Terraform
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "cf_dist_comment" {
  type = "string"
}

variable "cf_dist_origins" {
  type = "list"

  default = [{ 
    origin_domain_name                              = "example.com"
    origin_origin_path                              = ""
    default_root_object                             = "index.html"
    is_s3_origin                                    = false
    origin_http_port                                = 80
    origin_https_port                               = 443
    origin_protocol_policy                          = "match-viewer"
    origin_ssl_protocols                            = ["TLSv1.2"]
    cache_behavior_path_pattern                     = ""
    cache_behavior_allowed_methods                  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_behavior_cached_methods                   = ["HEAD", "GET"]
    cache_behavior_forwarded_values_query_string    = false
    cache_behavior_forwarded_values_cookies_forward = "none"
    cache_behavior_viewer_protocol_policy           = "allow-all"
    cache_behavior_min_ttl                          = 0
    cache_behavior_default_ttl                      = 0
    cache_behavior_max_ttl                          = 0
  }]
  
  description = "Enable creating cloudfront even with none existing origins"
}

variable "cf_dist_domain_name" {
  default = ""
  type = "string"
}

variable "cf_dist_lambda_s3bucket" {
  description = "The s3 bucket that contains the lambda function zip file."
}


variable "cf_dist_lambda_edge_zip_filepath" { 
  description = "The path of the zip file that contains lambda source code to uploade."
}


variable "cf_dist_lambda_edge_prefix" {
  default = ""
  description = "A proper prefix for lambda@edge function."
}


variable "cf_dist_domain_certificate_arn" {
  default = ""
  description = "The arn of the certificate that covers the custom domain if aliases is added to the cloudfront distribution."
}

variable "cf_dist_lambda_function_handler" {
  description = "Name of the file the contains lambda code without file extension. Example 'redirect-rules'"
}

variable "deploy_lambda_edge_func" {
  default = false
}

variable "enable_output_comments" {
  default = false
  description = "Enable this option activate helper comments to make it easier to distinguish between module outputs. If this module is called from another module then this option should be disabled"
}

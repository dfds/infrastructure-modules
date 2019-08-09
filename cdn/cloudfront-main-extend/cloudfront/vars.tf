# # --------------------------------------------------
# # Terraform
# # --------------------------------------------------

# variable "terraform_state_s3_bucket" {
#   type = "string"
# }

# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_acm_region" {
  type = "string"
}

variable "aws_lambda_edge_region" {
  type = "string"
}


variable "aws_assume_role_arn" {
  type = "string"
}

variable "cdn_origins" {
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

  #    type = list(object({
  #   name               = string
  #   pool_ipv6_prefixes = list(string)
  #   pool_ipv4_prefixes = list(string)
  #   cidr_ipv6          = string
  #   cidr_ipv4          = string
  #   enable_dhcp        = bool
  # }))
  description = "Enable creating main cdn even with none existing origins"
}

variable "cdn_comment" {
  type = "string"
}

variable "acm_certificate_arn" {
  default = ""
}

variable "cdn_domain_name" {
  default = ""
  type = "string"
}

variable "cf_lambda_s3bucket" {}

variable "lambda_zip_filepath" {}

variable "lambda_edge_zip_filepath" {
  
}


variable "cf_main_hosted_zone_deploy" {
  default = ""
}

variable "cf_main_dns_zone" {
  default = ""
}

variable "cf_route53_records_deploy" {
  default = false
}


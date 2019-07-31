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

variable "aws_assume_role_arn" {
  type = "string"
}

# variable "cdn_origins" {
#   type = "list"
# }

variable "cdn_comment" {
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
  
  description = "Enable creating main cdn even with none existing origins"
}
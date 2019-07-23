resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  price_class = "PriceClass_100"
  aliases = "${var.aliases}"

  viewer_certificate{
    cloudfront_default_certificate = "${var.acm_certificate_arn == "" ? true: false}"
    acm_certificate_arn = "${var.acm_certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1" # TLSv1.2_2018 ?    
  }

  http_version        = "http2"      # Supported HTTP Versions
  default_root_object = "index.html" # Default Root Object

  # Logging
  # Bucket for Logs
  # Log Prefix
  # Cookie Logging
  #  logging_config {
  #     include_cookies = false
  #     bucket          = "${aws_s3_bucket.logbucket.bucket_domain_name}"
  #     prefix          = "${var.project_name}-${var.environment}"
  #   }

  is_ipv6_enabled = false         
  comment         = "${var.cdn_comment}"
  enabled         = true

  dynamic "origin" {
    for_each = var.cdn_origins
    iterator = it
      content {
        domain_name = it.value.origin_domain_name
        origin_id = it.value.origin_domain_name
        origin_path = it.value.origin_origin_path
              
        dynamic "s3_origin_config" {
          for_each = it.value.is_s3_origin ? [1] : [] # apply s3 origin settings
          iterator = s3_origin_config
          content {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
          }          
        }

        dynamic "custom_origin_config" {
          for_each = it.value.is_s3_origin ? [] : [1] # apply custom origin settings
          iterator = custom_origin_config
          content {
            http_port              = it.value.origin_http_port
            https_port             = it.value.origin_https_port
            origin_protocol_policy = it.value.origin_protocol_policy #"match-viewer"
            origin_ssl_protocols   = it.value.origin_ssl_protocols # ["TLSv1.2"]
          }
      } 
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "ordered_cache_behavior" {
      for_each = length(var.cdn_origins) > 1 ? var.cdn_origins : [] # if only 1 record then we only define the default behavior
      iterator = it # alias for iterator. Otherwise the name would be of the dynamic blog "ordered_cache_behavior"

      content {
        target_origin_id = it.value.origin_domain_name # origin # TODO: Do not use domainname as id
        path_pattern = it.value.cache_behavior_path_pattern # path
        allowed_methods  = it.value.cache_behavior_allowed_methods # ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = it.value.cache_behavior_cached_methods # ["GET", "HEAD"]
        

        forwarded_values {
          query_string = it.value.cache_behavior_forwarded_values_query_string # false

          cookies {
            forward = it.value.cache_behavior_forwarded_values_cookies_forward #"none"
          }
        }

        viewer_protocol_policy = it.value.cache_behavior_viewer_protocol_policy # "allow-all"
        min_ttl                = it.value.cache_behavior_min_ttl #0
        default_ttl            = it.value.cache_behavior_default_ttl #86400
        max_ttl                = it.value.cache_behavior_max_ttl #31536000       
      }       
    }

  default_cache_behavior { 
    allowed_methods  = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_allowed_methods: ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"] }" # This to allow redirect 
    cached_methods   = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_cached_methods: ["HEAD", "GET"] }" 
    target_origin_id = var.cdn_origins[0].origin_domain_name # "dummy.dfds.com" # TODO: Do not use domainname as id

    forwarded_values {
      query_string = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_forwarded_values_query_string: false }" 

      cookies {
        forward = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_forwarded_values_cookies_forward: "none" }" 
      }
    }

    viewer_protocol_policy = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_viewer_protocol_policy: "allow-all" }" 
    min_ttl                = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_min_ttl: 0 }" 
    default_ttl            = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_default_ttl: 0 }" 
    max_ttl                = "${length(var.cdn_origins) == 1 ? var.cdn_origins[0].cache_behavior_max_ttl: 0 }" 
  }    
}

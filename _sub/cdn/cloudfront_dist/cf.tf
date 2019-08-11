locals {
  # Determine the certificate type
  is_iam_cert = var.iam_certificate_id != ""
  is_acm_cert = var.acm_certificate_arn != ""
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  price_class = "PriceClass_100"
  
  aliases = "${var.aliases}"

  # lifecycle {
  #   ignore_changes = ["viewer_certificate[0].ssl_support_method"]
  # }

  viewer_certificate {
    cloudfront_default_certificate = local.is_acm_cert # "${var.acm_certificate_arn == "" ? true: false}"
    acm_certificate_arn = local.is_acm_cert ? var.acm_certificate_arn : null #"${local.is_acm_cert ? null: var.acm_certificate_arn}" # "${var.acm_certificate_arn}"
    ssl_support_method = local.is_acm_cert ? "sni-only" : null # "${var.acm_certificate_arn == "" ? null: "sni-only" }" # "${var.acm_certificate_arn == "" ? "sni-only": ""}"
    minimum_protocol_version = "TLSv1" # TLSv1.2_2018 ?    
  }

  # dynamic "viewer_certificate" {
  #   for_each = length(var.acm_certificate_arn) == 0 ? [1] : []
    
  #   iterator = it

  #   content {      
  #     cloudfront_default_certificate = true
  #     minimum_protocol_version = "TLSv1"
  #   }          
  # }

  # dynamic "viewer_certificate" {
  #   for_each = length(var.acm_certificate_arn) > 0 ? [1] : []
    
  #   iterator = it
    
  #   content {      
  #     cloudfront_default_certificate = false
  #     acm_certificate_arn = "${var.acm_certificate_arn}"
  #     ssl_support_method = "sni-only"
  #     minimum_protocol_version = "TLSv1" # TLSv1.2_2018 ?   
  #   }          
  # }  

  # dynamic "viewer_certificate" {
  #   for_each = length(var.acm_certificate_arn) == 0 ? [1] : []
    
  #   iterator = it
    
  #   content {      
  #     cloudfront_default_certificate = true
  #     # acm_certificate_arn = "${var.acm_certificate_arn}"
  #     # ssl_support_method = "sni-only"
  #     minimum_protocol_version = "TLSv1" # TLSv1.2_2018 ?   
  #   }          
  # }  

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
  comment         = "${var.comment}"
  enabled         = true

  dynamic "origin" {
    for_each = var.origins
    iterator = it
      content {
        domain_name = it.value.origin_domain_name
        origin_id = it.value.origin_domain_name
        origin_path = it.value.origin_origin_path
              
        dynamic "s3_origin_config" {
          for_each = it.value.is_s3_origin ? [1] : [] # apply s3 origin settings
          iterator = s3_origin_config
          content {
            origin_access_identity = "${var.origin_access_identity}"
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
      for_each = length(var.origins) > 1 ? var.origins : [] # if only 1 record then we only define the default behavior
      iterator = it # alias for iterator. Otherwise the name would be of the dynamic blog "ordered_cache_behavior"

      content {
        target_origin_id = it.value.origin_domain_name # origin
        path_pattern = it.value.cache_behavior_path_pattern # path
        allowed_methods  = it.value.cache_behavior_allowed_methods
        cached_methods   = it.value.cache_behavior_cached_methods
        

        forwarded_values {
          query_string = it.value.cache_behavior_forwarded_values_query_string

          cookies {
            forward = it.value.cache_behavior_forwarded_values_cookies_forward
          }
        }

        viewer_protocol_policy = it.value.cache_behavior_viewer_protocol_policy
        min_ttl                = it.value.cache_behavior_min_ttl
        default_ttl            = it.value.cache_behavior_default_ttl
        max_ttl                = it.value.cache_behavior_max_ttl
      }       
    }

  default_cache_behavior { 
    allowed_methods  = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_allowed_methods: ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"] }" # This to allow redirect 
    cached_methods   = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_cached_methods: ["HEAD", "GET"] }" 
    target_origin_id = var.origins[0].origin_domain_name

    forwarded_values {
      query_string = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_forwarded_values_query_string: false }" 

      cookies {
        forward = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_forwarded_values_cookies_forward: "none" }" 
      }
    }

    viewer_protocol_policy = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_viewer_protocol_policy: "allow-all" }" 
    min_ttl                = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_min_ttl: 0 }" 
    default_ttl            = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_default_ttl: 0 }" 
    max_ttl                = "${length(var.origins) == 1 ? var.origins[0].cache_behavior_max_ttl: 0 }" 


    dynamic "lambda_function_association"{
      for_each = length(var.lambda_edge_qualified_arn) > 0 ? [1] : []
      iterator = it

      content{
        event_type   = "origin-request"
        lambda_arn   = "${var.lambda_edge_qualified_arn}"
        include_body = false
      }
    }
  }    
}
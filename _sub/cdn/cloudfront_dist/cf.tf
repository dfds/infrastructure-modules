locals {
  # Determine the certificate type
  # is_iam_cert = var.iam_certificate_id != ""
  is_acm_cert = var.acm_certificate_arn != ""
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  price_class = "PriceClass_100"
  
  aliases = "${var.aliases}"
  viewer_certificate {
    cloudfront_default_certificate = local.is_acm_cert ? false : true
    acm_certificate_arn = local.is_acm_cert ? var.acm_certificate_arn : null
    ssl_support_method = local.is_acm_cert ? "sni-only" : null
    minimum_protocol_version = local.is_acm_cert ? var.custom_ssl_security_policy: null
  }


  http_version        = "http2"      # Supported HTTP Versions
  default_root_object = "index.html" # Default Root Object

  dynamic "logging_config" {
    for_each = var.logging_enable ? [1] : []
    content {
      include_cookies = "${var.logging_include_cookies}"
      bucket          = "${var.logging_bucket}"
      prefix          = "${var.logging_prefix}"      
    }
  }


  is_ipv6_enabled = false         
  comment         = "${var.comment}"
  enabled         = true

  dynamic "origin" {
    for_each = var.origins
    iterator = it
      content {
        domain_name = it.value.domain_name
        origin_id = it.value.origin_id
        origin_path = lookup(it.value, "origin_path", null)
              
        dynamic "s3_origin_config" {
          for_each = lookup(it.value, "is_s3_origin", false) ? [1] : [] # apply s3 origin settings
          iterator = s3_origin_config
          content {
            origin_access_identity = "${var.origin_access_identity}"
          }          
        }

        dynamic "custom_origin_config" {
          for_each = lookup(it.value, "is_s3_origin", false) ? [] : [1] # apply custom origin settings
          iterator = custom_origin_config
          content {
            http_port              = lookup(it.value, "http_port", 80)
            https_port             = lookup(it.value, "https_port", 443)
            origin_protocol_policy = lookup(it.value, "protocol_policy", "match-viewer")
            origin_ssl_protocols   = lookup(it.value, "ssl_protocols", ["TLSv1.2"]) 
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
      for_each = length(var.cache_behaviors) > 1 ? var.cache_behaviors : [] # if only 1 record then we only define the default behavior
      iterator = it # alias for iterator. Otherwise the name would be of the dynamic blog "ordered_cache_behavior"

      content {
        target_origin_id = it.value.origin_id # origin
        path_pattern = it.value.path_pattern # path
        allowed_methods  = lookup(it.value, "allowed_methods", ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
        cached_methods   = lookup(it.value, "cached_methods", ["HEAD", "GET"])
        

        forwarded_values {
          query_string = it.value.forwarded_values_query_string

          cookies {
            forward = it.value.forwarded_values_cookies_forward
          }
        }

        viewer_protocol_policy = lookup(it.value, "viewer_protocol_policy", "allow-all")
        min_ttl                = lookup(it.value, "min_ttl", null)
        default_ttl            = lookup(it.value, "default_ttl", null)
        max_ttl                = lookup(it.value, "max_ttl", null)

        dynamic "lambda_function_association"{
          for_each = lookup(it.value, "lambda_function_association_lambda_arn", null) != null ? [1] : []
          iterator = it_sub

          content{
            event_type   = lookup(it.value, "lambda_function_association_event_type", "origin-request")
            lambda_arn   = it.value.lambda_function_association_lambda_arn
            include_body = lookup(it.value, "lambda_function_association_include_body", false)
          }
        }        
      }       
    }

  default_cache_behavior { 
    allowed_methods  = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "allowed_methods", ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]) : ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"] }" # This to allow redirect 
    cached_methods   = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "cached_methods", ["HEAD", "GET"]) : ["HEAD", "GET"] }" 
    target_origin_id = var.cache_behaviors[0].origin_id

    forwarded_values {
      query_string = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "forwarded_values_query_string", false): false }" 

      cookies {
        forward = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "forwarded_values_cookies_forward", "none") : "none" }" 
      }
    }

    viewer_protocol_policy = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "viewer_protocol_policy", "allow-all"): "allow-all"}"
    min_ttl                = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "min_ttl", null) : null }"
    default_ttl            = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "default_ttl", null): null}"
    max_ttl                = "${length(var.origins) == 1 ? lookup(var.cache_behaviors[0], "max_ttl", null) : null}"


    dynamic "lambda_function_association"{
      for_each = lookup(var.cache_behaviors[0], "lambda_function_association_lambda_arn", null) != null ? [1] : []
      iterator = it

      content{
        event_type   = lookup(var.cache_behaviors[0], "lambda_function_association_event_type", "origin-request")
        lambda_arn   = var.cache_behaviors[0].lambda_function_association_lambda_arn
        include_body = lookup(var.cache_behaviors[0], "lambda_function_association_include_body", false)
      }
    }
  }    
}
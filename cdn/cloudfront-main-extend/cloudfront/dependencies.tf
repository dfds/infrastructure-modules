locals {
    root_redirect_api_function_domain_name_no_protocol = "${replace(module.aws_api_gateway.invoke_url, "https://","")}"
    root_redirect_api_function_domain_name = "${replace(local.root_redirect_api_function_domain_name_no_protocol, "/","")}"    
    redirect_origin = [{
        origin_domain_name = local.root_redirect_api_function_domain_name
        origin_origin_path = "/LATEST/root-redirect"
        default_root_object = "index.html"
        is_s3_origin = false
        origin_http_port = 80
        origin_https_port = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols = ["TLSv1.2"]
        cache_behavior_path_pattern = ""
        cache_behavior_allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cache_behavior_cached_methods = ["HEAD", "GET"]
        cache_behavior_forwarded_values_query_string = true
        cache_behavior_forwarded_values_cookies_forward = "all"
        cache_behavior_viewer_protocol_policy = "allow-all"
        cache_behavior_min_ttl = 0
        cache_behavior_default_ttl = 0
        cache_behavior_max_ttl = 0
        }
    ]
}


# Find a certificate that is issued
data "aws_acm_certificate" "cf_domain_cert" {
  provider = "aws.acm"

  domain   = "www.${var.cf_main_dns_zone}"
  statuses = ["ISSUED"]
}
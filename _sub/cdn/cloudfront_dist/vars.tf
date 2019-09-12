variable "origins" {
  description = "List of origins that cloudfront should support."
}

variable "cache_behaviors" {
  description = "List of origins that cloudfront should support."
}


variable "comment" {
  description = "A short description of the cloudfront distribution. Comments used to enable the user to distinquish between cloudfront distributions. It's also used to construct a proper prefix for lambda@edge function."
  default = ""
}

variable "acm_certificate_arn" {
  description = "The arn of the certificate that covers the custom domain if aliases is added to the cloudfront distribution."
  default = ""
}

variable "custom_ssl_security_policy" {
  description = "Choose the security policy that you want CloudFront to use for HTTPS connections. A security policy determines two settings: the SSL/TLS protocol that CloudFront uses to communicate with viewers, and the cipher that CloudFront uses to encrypt the content that it returns to viewers. When you use a custom SSL certificate and SNI, you must use TLSv1 or later. We recommend that you specify TLSv1.1_2016 unless your users are using browsers or devices that do not support TLSv1.1 or later. When you use a custom SSL certificate and dedicated IP addresses, we recommend that you use TLSv1. In this configuration, the TLSv1_2016, TLSv1.1_2016 and TLSv1.2_2018 security policies are not available"
  default = "TLSv1.2_2018"
}


variable "aliases" {
  default = []
  type = "list"
  description = "The list of custom domains to be used to reach the cloudfront distribution instead of the auto-generated cloudfront domain (xxxx.cloudfront.net)."
}

variable "origin_access_identity" {
  default = ""
  description = "The path that identifies the origin access identity to be used for accessing s3 bucket origins."
}

variable "logging_enable" {
  default = false
}

variable "logging_include_cookies" {
  description = "Specifies whether you want CloudFront to include cookies in access logs (default: false)"
  default = false
}


variable "logging_bucket" {
  
}

variable "logging_prefix" {
  
}
variable "origins" {
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

variable "aliases" {
  default = []
  type = "list"
  description = "The list of custom domains to be used to reach the cloudfront distribution instead of the auto-generated cloudfront domain (xxxx.cloudfront.net)."
}

variable "origin_access_identity" {
  default = ""
  description = "The path that identifies the origin access identity to be used for accessing s3 bucket origins."
}

variable "lambda_edge_qualified_arn" {
  description = "The arn of the published version of the lambda@edge function. At the moment, it's required to have the function is created in US-East-1 region."
  default = ""
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

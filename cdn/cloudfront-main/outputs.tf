# output "aws_cloudfront_distribution_www_domain_name" {
#   value = "${module.aws_cloudfront_www.distribution_domain_name} (${var.cdn_comment})"
# }

# output "aws_cloudfront_distribution_redirect_domain_name" {
#   value = "${module.aws_cloudfront_redirect.distribution_domain_name} (${var.cdn_comment})"
# }

output "s3_object_key" {
  value = "${module.s3_object_upload.s3_object_key} Test!!"
}

output "sometest" {
  value = "somevalue"
}

output "aws_cloudfront_oai_arn" {
  value = "${module.aws_cloudfront.oai_arn} (${var.cdn_comment})"
}

output "aws_cloudfront_distribution_domain_name" {
  value = "${module.aws_cloudfront.distribution_domain_name} (${var.cdn_comment})"
}
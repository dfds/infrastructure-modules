output "aws_cloudfront_oai_arn" {
  value = "${module.aws_cf_oai.oai_arn} (${var.cf_dist_comment})"
}

output "aws_cloudfront_distribution_domain_name" {
  value = "${module.aws_cf_dist.distribution_domain_name} (${var.cf_dist_comment})"
}
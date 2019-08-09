output "aws_cloudfront_oai_arn" {
  # value = "${module.aws_cf_oai.oai_arn} (${var.cf_dist_comment})"

  value = "${var.enable_output_comments ? "${module.aws_cf_oai.oai_arn} (${var.cf_dist_comment})" : module.aws_cf_oai.oai_arn }" 
}

output "aws_cloudfront_distribution_domain_name" {
  value = "${var.enable_output_comments ? "${module.aws_cf_dist.distribution_domain_name} (${var.cf_dist_comment})" : module.aws_cf_dist.distribution_domain_name }" 
}



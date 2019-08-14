output "aws_cloudfront_oai_arn" {
  value = "${var.enable_output_comments ? "${module.aws_cf_oai.oai_arn} (${var.cf_dist_comment})" : module.aws_cf_oai.oai_arn }" 
}


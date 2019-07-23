output "oai_arn" {
  value = "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"  
}

output "distribution_domain_name" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}

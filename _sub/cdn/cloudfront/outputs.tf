output "distribution_domain_name" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}

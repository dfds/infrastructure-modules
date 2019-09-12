output "distribution_domain_name" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}

output "distribution_hosted_zone_id" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id}"
}
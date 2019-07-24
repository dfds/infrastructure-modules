output "origin_access_identity" {
  value = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
}

output "oai_arn" {
  value = "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"  
}
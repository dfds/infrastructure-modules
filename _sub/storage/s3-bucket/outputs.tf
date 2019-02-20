output "bucket_name" {
  value = "${element(concat(aws_s3_bucket.container-registry.*.id, list("")), 0)}"
}

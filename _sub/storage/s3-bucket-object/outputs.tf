output "id" {
  value = element(concat(aws_s3_object.object.*.id, [""]), 0)
}


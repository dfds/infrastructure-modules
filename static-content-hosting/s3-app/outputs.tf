# --------------------------------------------------
# 
# --------------------------------------------------

output "aws_s3_webapp_domain_name" {
  value = "${module.s3_app.bucket_domain_name} (${var.s3_app_bucket})"
}

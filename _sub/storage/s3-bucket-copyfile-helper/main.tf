resource "null_resource" "copyfileToBucket" {
  count = "${var.deploy}"
  provisioner "local-exec" {
    command = "aws s3 cp ${var.file} s3://${var.target_bucket}"
  }

  triggers {
    build_number = "${timestamp()}"
  }
}
resource "aws_directory_service_directory" "ad" {
  name     = var.name
  type     = "MicrosoftAD"
  password = var.password
  edition  = var.edition

  vpc_settings {
    vpc_id     = data.aws_subnet.subnet_0.vpc_id
    subnet_ids = var.subnet_ids
  }
}

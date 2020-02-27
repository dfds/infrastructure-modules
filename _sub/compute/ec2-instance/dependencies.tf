data "aws_ami" "ami" {

  most_recent = true

  filter {
    name   = "platform"
    values = var.ami_platform_filters
  }

  filter {
    name   = "name"
    values = var.ami_name_filters
  }

  owners = var.ami_owners

}

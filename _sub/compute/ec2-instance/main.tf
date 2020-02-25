resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ami.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  get_password_data           = var.get_password_data

  tags = {
    Name = var.name
  }
}

resource "aws_iam_role" "role" {
  name_prefix = "ec2-${var.name}-"
  description = "For ${var.name} EC2 instance"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role_policy_attachment" "attach" {
  count      = signum(length(var.aws_managed_policy))
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/${var.aws_managed_policy}"
}

resource "aws_iam_instance_profile" "profile" {
  name_prefix = "ec2-${var.name}-"
  role        = aws_iam_role.role.name

  lifecycle {
    create_before_destroy = true
  }

}

# tfsec:ignore:aws-ec2-enforce-http-token-imds tfsec:ignore:aws-ec2-enable-at-rest-encryption
resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ami.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  user_data                   = var.user_data
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  get_password_data           = var.get_password_data
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }

}

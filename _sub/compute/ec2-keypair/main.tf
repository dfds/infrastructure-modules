resource "aws_key_pair" "pair" {
  key_name_prefix = "${var.name}-"
  public_key      = var.public_key
}

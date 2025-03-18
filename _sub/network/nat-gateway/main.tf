resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.ng.id
  subnet_id     = var.subnet_id

  tags = var.tags

  depends_on = [aws_eip.ng]
}

resource "aws_eip" "ng" {
  domain = "vpc"
  tags   = var.tags
}

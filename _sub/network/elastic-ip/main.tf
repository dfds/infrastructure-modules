resource "aws_eip" "ip" {
  instance = var.instance
  vpc      = true
}

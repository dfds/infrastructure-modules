data "aws_route53_zone" "selected" {
  name         = "${var.root_dns}"
  private_zone = false

  provider = "aws.rootdns"
}
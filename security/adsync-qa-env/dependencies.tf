data "aws_route53_zone" "workload" {
  name         = "${var.workload_dns_zone_name}."
  private_zone = false
}

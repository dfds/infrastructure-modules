output "subnet_ids" {
  value = ["${aws_subnet.subnet.*.id}"]
}
  # value = "${element(concat(aws_lb.nlb.*.dns_name, list("")), 0)}"
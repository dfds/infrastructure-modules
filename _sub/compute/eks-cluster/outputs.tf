output "autoscale_security_group" {
  value = "${aws_security_group.eks-cluster.id}"
}

output "vpc_id" {
  value = "${aws_vpc.eks.id}"
}

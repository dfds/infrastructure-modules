output "subnet_ids" {
  value = aws_subnet.subnet.*.id
}

output "subnets" {
  value = [for sn in aws_subnet.subnet : {
    id : sn.id,
    availability_zone : sn.availability_zone,
  }]
}

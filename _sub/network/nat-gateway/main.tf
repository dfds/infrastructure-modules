resource "aws_nat_gateway" "ng" {
    allocation_id = aws_eip.ng[0].id
    subnet_id = var.subnet_id

    tags = var.tags

    depends_on = [ aws_eip.ng ]
}

resource "aws_eip" "ng" {
    count = var.use_static_ip ? 1 : 0
    domain = "vpc"
    tags = var.tags
}
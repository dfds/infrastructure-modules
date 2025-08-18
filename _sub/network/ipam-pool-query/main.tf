data "aws_vpc_ipam_pool" "this" {
  filter {
    name   = "description"
    values = [var.ipam_pool_description]
  }

  filter {
    name   = "locale"
    values = [var.aws_region]
  }
}

resource "aws_vpc_ipam_preview_next_cidr" "this" {
  ipam_pool_id   = data.aws_vpc_ipam_pool.this.id
  netmask_length = var.ipam_cidr_prefix
}

# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43" # Dir: "WaitForState" timeout
  # version 2.7 -> 2.11: requires state cleanup
  # version 2.12 -> 2.50: "WaitForState" timeout

  # profile = "qa-orgrole"

  #   assume_role {
  #     role_arn = var.aws_assume_role_arn
  #   }
}

# --------------------------------------------------
# Local variables
# --------------------------------------------------

locals {
  default_resource_name = "adsync-qa"
}

# --------------------------------------------------
# Network infrastructure
# --------------------------------------------------

module "vpc" {
  source     = "../../_sub/network/vpc"
  name       = local.default_resource_name
  cidr_block = var.vpc_cidr_block
}

module "subnets" {
  source      = "../../_sub/network/vpc-subnet"
  name        = local.default_resource_name
  vpc_id      = module.vpc.id
  cidr_blocks = var.subnet_cidr_blocks
}

# --------------------------------------------------
# Network security
# --------------------------------------------------

module "securitygroup" {
  source      = "../../_sub/compute/ec2-securitygroup"
  name        = local.default_resource_name
  description = "ADSync QA"
  vpc_id      = module.vpc.id
}

module "securitygrouprule_rdp_tcp" {
  source            = "../../_sub/compute/ec2-sgrule-cidr"
  security_group_id = module.securitygroup.id
  description       = "Allow RDP access from internet"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 3389
  to_port           = 3389
}

module "securitygrouprule_rdp_udp" {
  source            = "../../_sub/compute/ec2-sgrule-cidr"
  security_group_id = module.securitygroup.id
  description       = "Allow RDP access from internet"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/24"]
  from_port         = 3389
  to_port           = 3389
}

# --------------------------------------------------
# Internet access
# --------------------------------------------------

module "vpc_internet_gateway" {
  source = "../../_sub/network/internet-gateway"
  name   = local.default_resource_name
  vpc_id = module.vpc.id
}

module "vpc_route_table" {
  source     = "../../_sub/network/route-table"
  name       = local.default_resource_name
  vpc_id     = module.vpc.id
  gateway_id = module.vpc_internet_gateway.id
}

module "route_table_assoc" {
  source         = "../../_sub/network/route-table-assoc"
  subnet_ids     = module.subnets.ids
  route_table_id = module.vpc_route_table.id
}

# --------------------------------------------------
# Active Directory
# --------------------------------------------------

module "activedirectory" {
  source     = "../../_sub/security/active-directory"
  name       = var.ad_name
  password   = var.ad_password
  edition    = var.ad_edition
  subnet_ids = slice(module.subnets.ids, 0, 2) # exactly two subnets, in different AZs, are required
}

# --------------------------------------------------
# Server
# --------------------------------------------------

module "ec2_keypair" {
  source     = "../../_sub/compute/ec2-keypair"
  name       = local.default_resource_name
  public_key = var.ec2_public_key
}

module "ec2_instance" {
  source                      = "../../_sub/compute/ec2-instance"
  instance_type               = var.ec2_instance_type
  key_name                    = module.ec2_keypair.key_name
  name                        = "adsync"
  ami_platform_filters        = ["windows"]
  ami_name_filters            = ["*Server-${var.ec2_windows_server_version}-English-Full-Base*"]
  ami_owners                  = ["amazon"]
  vpc_security_group_ids      = [module.securitygroup.id]
  subnet_id                   = element(module.subnets.ids, 2)
  associate_public_ip_address = true
  get_password_data           = true
  private_key_path            = var.ec2_private_key_path
}

# module "elastic_ip" {
#   source   = "../../_sub/network/elastic-ip"
#   instance = module.ec2_instance.id
# }

module "ec2_dns_record" {
  source       = "../../_sub/network/route53-record"
  zone_id      = data.aws_route53_zone.workload.id
  record_name  = ["adsync"]
  record_type  = "CNAME"
  record_value = module.ec2_instance.public_dns
  record_ttl   = 60
}

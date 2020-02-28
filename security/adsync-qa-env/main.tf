# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"

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


resource "aws_vpc_dhcp_options" "ad" {
  domain_name         = var.ad_name
  domain_name_servers = module.activedirectory.dns_ip_addresses
}

resource "aws_vpc_dhcp_options_association" "ad" {
  vpc_id          = module.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.ad.id
}


# --------------------------------------------------
# Server
# --------------------------------------------------

module "ec2_keypair" {
  source     = "../../_sub/compute/ec2-keypair"
  name       = local.default_resource_name
  public_key = var.ec2_public_key
}

data "template_file" "user_data" {
  template = file("${path.module}/ec2_user_data")
  vars = {
    ado_access_token     = var.ado_access_token
    ado_org_name         = var.ado_org_name
    ado_project_name     = var.ado_project_name
    ado_deployment_group = var.ado_deployment_group
  }
}

module "ec2_instance" {
  source                      = "../../_sub/compute/ec2-instance"
  instance_type               = var.ec2_instance_type
  key_name                    = module.ec2_keypair.key_name
  name                        = "adsync"
  user_data                   = data.template_file.user_data.rendered
  ami_platform_filters        = ["windows"]
  ami_name_filters            = ["*Server-${var.ec2_windows_server_version}-English-Full-Base*"]
  ami_owners                  = ["amazon"]
  vpc_security_group_ids      = [module.securitygroup.id]
  subnet_id                   = element(module.subnets.ids, 2)
  associate_public_ip_address = true
  get_password_data           = true
  aws_managed_policy          = "AmazonEC2RoleforSSM"
}

module "ec2_dns_record" {
  source       = "../../_sub/network/route53-record"
  zone_id      = data.aws_route53_zone.workload.id
  record_name  = ["adsync"]
  record_type  = "CNAME"
  record_value = module.ec2_instance.public_dns
  record_ttl   = 60
}

locals {
  ssm_document_map = {
    "schemaVersion" = "1.0"
    "description"   = "Join an instance to a the ${var.ad_name} domain"
    "runtimeConfig" = {
      "aws:domainJoin" = {
        "properties" = {
          "directoryId"    = module.activedirectory.id
          "directoryName"  = var.ad_name
          "dnsIpAddresses" = module.activedirectory.dns_ip_addresses
        }
      }
    }
  }
  ssm_document_json = jsonencode(local.ssm_document_map)
}

resource "aws_ssm_document" "doc" {
  name          = "Join_${var.ad_name}_domain"
  document_type = "Command"
  content       = local.ssm_document_json
}

resource "aws_ssm_association" "assoc" {
  name        = aws_ssm_document.doc.name
  instance_id = module.ec2_instance.id
}

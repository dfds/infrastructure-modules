# --------------------------------------------------
# Get remote state of cluster deployment
# --------------------------------------------------

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "${var.aws_region}/k8s-${var.eks_cluster_name}/cluster/terraform.tfstate"
    region = var.terraform_state_region
  }
}


# --------------------------------------------------
# Cluster metadata and authenticate
# --------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster_name
}


# --------------------------------------------------
# Generate EKS fully-qualified domain name
# --------------------------------------------------

locals {
  eks_fqdn = "${var.eks_cluster_name}.${var.workload_dns_zone_name}"
}


# --------------------------------------------------
# Determine parent DNS zone name
# --------------------------------------------------

locals {
  workload_dns_zone_list = split(".", var.workload_dns_zone_name)
  core_dns_zone_list = slice(
    local.workload_dns_zone_list,
    1,
    length(local.workload_dns_zone_list),
  )
  core_dns_zone_name = join(".", local.core_dns_zone_list)
}


# --------------------------------------------------
# Get Route 53 zones and ids
# --------------------------------------------------

data "aws_route53_zone" "workload" {
  name         = "${var.workload_dns_zone_name}."
  private_zone = false
}

data "aws_route53_zone" "core" {
  count        = signum(length(var.traefik_alb_auth_core_alias))
  name         = "${local.core_dns_zone_name}."
  private_zone = false
  provider     = aws.core
}

# Get DNS zone IDs
locals {
  workload_dns_zone_id = element(concat(data.aws_route53_zone.workload.*.zone_id, [""]), 0)
  core_dns_zone_id     = element(concat(data.aws_route53_zone.core.*.zone_id, [""]), 0)
}


# --------------------------------------------------
# Generate Traefik authenticated ALB app registration reply URLs
# --------------------------------------------------

locals {
  traefik_alb_auth_endpoints = concat(
    ["internal.${local.eks_fqdn}"],
    var.traefik_alb_auth_core_alias,
  )
  traefik_alb_auth_appreg_reply_join        = "^${join("$,^", local.traefik_alb_auth_endpoints)}$"
  traefik_alb_auth_appreg_reply_replace_pre = replace(local.traefik_alb_auth_appreg_reply_join, "^", "https://")
  traefik_alb_auth_appreg_reply_replace_end = replace(
    local.traefik_alb_auth_appreg_reply_replace_pre,
    "$",
    "/oauth2/idpresponse",
  )
  traefik_alb_auth_appreg_reply_urls = split(",", local.traefik_alb_auth_appreg_reply_replace_end)
}

locals {
  kubeconfig_path = pathexpand("~/.kube/${var.eks_cluster_name}.config")
}


# --------------------------------------------------
# CloudWatch Logs IAM role
# --------------------------------------------------

data "aws_caller_identity" "logs" {
  provider = aws.logs
}

locals {
  cloudwatchlogs_assume_role_policy = {
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Sid"    = ""
        "Effect" = "Allow"
        "Principal" = {
          "AWS" = module.kiam_deploy.server_role_arn
        }
        "Action" = "sts:AssumeRole"
      }
    ]
  }

  cloudwatchlogs_policy = {
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Sid"    = "ReadLogs"
        "Effect" = "Allow"
        "Action" = [
          "logs:Describe*",
          "logs:Get*",
          "logs:List*"
        ]
        "Resource" = "*"
      },
      {
        "Sid"      = "LogStream"
        "Effect"   = "Allow"
        "Action"   = "logs:*"
        "Resource" = "arn:aws:logs:*:${data.aws_caller_identity.logs.account_id}:log-group:/k8s/${var.eks_cluster_name}/*:log-stream:*"
      },
      {
        "Sid"      = "LogGroup"
        "Effect"   = "Allow"
        "Action"   = "logs:*"
        "Resource" = "arn:aws:logs:*:${data.aws_caller_identity.logs.account_id}:log-group:/k8s/${var.eks_cluster_name}/*"
      }
    ]
  }
}
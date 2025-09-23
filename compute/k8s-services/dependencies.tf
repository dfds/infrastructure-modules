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
# Monitoring namespace name
# --------------------------------------------------

locals {
  monitoring_namespace_name = "monitoring"
}


# --------------------------------------------------
# Get Route 53 zones and ids
# --------------------------------------------------

data "aws_route53_zone" "workload" {
  name         = "${var.workload_dns_zone_name}."
  private_zone = false
}

data "aws_route53_zone" "core" {
  count        = signum(length(var.traefik_alb_auth_core_alias) + length(var.traefik_alb_anon_core_alias))
  name         = "${local.core_dns_zone_name}."
  private_zone = false
  provider     = aws.core
}

# Get DNS zone IDs
locals {
  workload_dns_zone_id = element(concat(data.aws_route53_zone.workload[*].zone_id, [""]), 0)
  core_dns_zone_id     = element(concat(data.aws_route53_zone.core[*].zone_id, [""]), 0)
}


# --------------------------------------------------
# Generate Traefik authenticated ALB app registration reply URLs
# --------------------------------------------------

locals {
  traefik_alb_auth_endpoints = concat(
    var.traefik_blue_variant_deploy || var.traefik_green_variant_deploy ? concat(
      [
        "internal.${local.eks_fqdn}"
      ],
      var.traefik_alb_auth_core_alias
    ) : [],
    var.traefik_blue_variant_deploy && var.traefik_green_variant_deploy ?
    [
      "traefik-blue-variant.${local.eks_fqdn}:8443",
      "traefik-green-variant.${local.eks_fqdn}:9443"
    ] : [],
    var.traefik_blue_variant_deploy ?
    [
      "traefik-blue-variant.${local.eks_fqdn}"
    ] : [],
    var.traefik_green_variant_deploy ?
    [
      "traefik-green-variant.${local.eks_fqdn}"
    ] : [],
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
  oidc_issuer = trim(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
}


# --------------------------------------------------
# Loadbalancer service account
# --------------------------------------------------

data "aws_elb_service_account" "main" {}

# --------------------------------------------------
# Loadbalancer access logs S3 bucket policy
# --------------------------------------------------

locals {
  alb_access_log_bucket_name   = "dfds-k8s-${var.eks_cluster_name}-alb-access-logs"
  alb_access_log_bucket_policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.alb_access_log_bucket_name}/*/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

# --------------------------------------------------
# Blackbox Exporter
# --------------------------------------------------

locals {
  blackbox_exporter_monitoring_atlantis = var.atlantis_deploy ? [{
    "name"   = "atlantis"
    "url"    = "http://atlantis.${var.atlantis_namespace}/healthz"
    "module" = "http_2xx"
  }] : []

  blackbox_exporter_monitoring_traefik_blue_variant = var.traefik_blue_variant_deploy ? [{
    "name"   = "traefik-blue-variant"
    "url"    = "http://traefik-blue-variant.traefik-blue-variant:${var.blackbox_exporter_monitoring_traefik_blue_variant_port}/ping"
    "module" = "http_2xx"
  }] : []

  blackbox_exporter_monitoring_traefik_green_variant = var.traefik_green_variant_deploy ? [{
    "name"   = "traefik-green-variant"
    "url"    = "http://traefik-green-variant.traefik-green-variant:${var.blackbox_exporter_monitoring_traefik_green_variant_port}/ping"
    "module" = "http_2xx"
  }] : []


  blackbox_exporter_monitoring_targets = concat(
    local.blackbox_exporter_monitoring_atlantis,
    local.blackbox_exporter_monitoring_traefik_blue_variant,
    local.blackbox_exporter_monitoring_traefik_green_variant,
    var.blackbox_exporter_monitoring_targets
  )
}

# --------------------------------------------------
# Flux CD
# --------------------------------------------------

locals {
  fluxcd_apps_repo_url = "${var.fluxcd_apps_git_provider_url}${var.fluxcd_apps_repo_owner}/${var.fluxcd_apps_repo_name}"
}

# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

locals {
  enable_inactivity_cleanup = (
    var.enable_inactivity_cleanup && data.terraform_remote_state.cluster.outputs.eks_is_sandbox ? true : false
  )
}


# --------------------------------------------------
# IAM role for Route53 zone delegation
# --------------------------------------------------
data "aws_caller_identity" "hostedzone_account" {
  provider     = aws.core
}

locals {
  external_dns_role_name = "${var.eks_cluster_name}-external-dns"
  external_dns_namespace_name = "external-dns"
  external_dns_serviceaccount_name = "external-dns"
  external_dns_role_assume_policy_name = "assume-role-external-dns"
  external_dns_role_name_cross_account = "${var.eks_cluster_name}-external-dns-cross-accounts"
  external_dns_role_name_cross_account_assume_policy_name = "allowExternalDNSUpdates"
}

data "aws_iam_policy_document" "external_dns_role_assume_policy" { # only allow production cluster to assume this role
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.hostedzone_account.account_id}:role/${local.external_dns_role_name_cross_account}",
    ]
  }
}


# if ingress is annotated with  external-dns.alpha.kubernetes.io/hostname: <loadbalancer dns name>
# then it will create a record set in route53 with this name pointing to the loadbalancer otherwise there will be no record created
# ---------------------------------------------------
data "aws_iam_policy_document" "external_dns_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.workload_account.account_id}:oidc-provider/${local.oidc_issuer}",
        #"arn:aws:iam::194351241786:oidc-provider/${local.oidc_issuer}", <---- check if this is correct!!
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${local.external_dns_namespace_name}:${local.external_dns_serviceaccount_name}"]
      variable = "${local.oidc_issuer}:sub"
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${local.oidc_issuer}:aud"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

data "aws_iam_policy_document" "external_dns_core_route53_access_policy" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources",
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "external_dns_core_route53_access_policy_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.workload_account.account_id}:root"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_caller_identity" "workload_account" {
}
# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------

module "ipam_pool_query" {
  count                 = var.eks_ipam_enabled ? 1 : 0
  source                = "../../_sub/network/ipam-pool-query"
  ipam_pool_description = var.eks_ipam_pool_description
  aws_region            = var.aws_region
  ipam_cidr_prefix      = var.eks_ipam_prefix_size
}

locals {
  eks_cluster_cidr_block     = var.eks_ipam_enabled && length(var.eks_managed_worker_subnets) == 0 ? try(module.ipam_pool_query[0].cidr, var.eks_cluster_cidr_block) : var.eks_cluster_cidr_block
  managed_subnets_calculated = cidrsubnets(local.eks_cluster_cidr_block, 2, 2, 2, 2)
  cluster_reserved_cidr      = local.managed_subnets_calculated[0] # Reserved for the control plane subnets
  managed_subnet_az_a        = local.managed_subnets_calculated[1] # Worker nodes subnet for availability zone a
  managed_subnet_az_b        = local.managed_subnets_calculated[2] # Worker nodes subnet for availability zone b
  managed_subnet_az_c        = local.managed_subnets_calculated[3] # Worker nodes subnet for availability zone c
  vpc_cidr_prefix            = tonumber(substr(local.eks_cluster_cidr_block, -2, -1))
  # This is used to determine the prefix length for the subnets, by splitting the CIDR block for the subnets
  # into smaller chunks based on the prefix length.
  # In each subnet calculation, we need to ensure that first and last IP addresses are reserved for the VPC and broadcast address respectively.
  # This is calculated by using slice to remove the first element of the list of prefixes, and simply omit to create the last possible prefix.
  # For VPC cidr prefixes with values 18, 19, and 20, we are reserving the first and last 126 IP addresses.
  # For VPC cidr prefix with /17, we are reserving the first and last 254 IP addresses.
  # For VPC cidr prefix with /16, we are keeping backward compatibility with existing deployments.
  # Tool for calculating the subnets: https://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.64.0&mask=18&division=15.f051

  worker_subnets_calculated = [
    {
      availability_zone = format("%sa", var.aws_region)
      subnet_cidr       = local.managed_subnet_az_a
      prefix_reservations_cidrs = local.vpc_cidr_prefix == 20 ? slice(cidrsubnets(local.managed_subnet_az_a, 3, 3, 2, 2, 3), 1, 5) : (
        local.vpc_cidr_prefix == 19 ? slice(cidrsubnets(local.managed_subnet_az_a, 4, 4, 3, 2, 2, 3, 4), 1, 7) : (
          local.vpc_cidr_prefix == 18 ? slice(cidrsubnets(local.managed_subnet_az_a, 5, 5, 4, 3, 2, 2, 3, 4, 5), 1, 9) : (
            local.vpc_cidr_prefix == 17 ? slice(cidrsubnets(local.managed_subnet_az_a, 5, 5, 4, 3, 3, 3, 3, 3, 3, 4, 5), 1, 11) : (
              local.vpc_cidr_prefix == 16 ? slice(cidrsubnets(local.managed_subnet_az_a, 4, 4, 3, 2, 2, 3, 4), 1, 7) : []
            )
          )
        )
      )
    },
    {
      availability_zone = format("%sb", var.aws_region)
      subnet_cidr       = local.managed_subnet_az_b
      prefix_reservations_cidrs = local.vpc_cidr_prefix == 20 ? slice(cidrsubnets(local.managed_subnet_az_b, 3, 3, 2, 2, 3), 1, 5) : (
        local.vpc_cidr_prefix == 19 ? slice(cidrsubnets(local.managed_subnet_az_b, 4, 4, 3, 2, 2, 3, 4), 1, 7) : (
          local.vpc_cidr_prefix == 18 ? slice(cidrsubnets(local.managed_subnet_az_b, 5, 5, 4, 3, 2, 2, 3, 4, 5), 1, 9) : (
            local.vpc_cidr_prefix == 17 ? slice(cidrsubnets(local.managed_subnet_az_b, 5, 5, 4, 3, 3, 3, 3, 3, 3, 4, 5), 1, 11) : (
              local.vpc_cidr_prefix == 16 ? slice(cidrsubnets(local.managed_subnet_az_b, 4, 4, 3, 2, 2, 3, 4), 1, 7) : []
            )
          )
        )
      )
    },
    {
      availability_zone = format("%sc", var.aws_region)
      subnet_cidr       = local.managed_subnet_az_c
      prefix_reservations_cidrs = local.vpc_cidr_prefix == 20 ? slice(cidrsubnets(local.managed_subnet_az_c, 3, 3, 2, 2, 3), 1, 5) : (
        local.vpc_cidr_prefix == 19 ? slice(cidrsubnets(local.managed_subnet_az_c, 4, 4, 3, 2, 2, 3, 4), 1, 7) : (
          local.vpc_cidr_prefix == 18 ? slice(cidrsubnets(local.managed_subnet_az_c, 5, 5, 4, 3, 2, 2, 3, 4, 5), 1, 9) : (
            local.vpc_cidr_prefix == 17 ? slice(cidrsubnets(local.managed_subnet_az_c, 5, 5, 4, 3, 3, 3, 3, 3, 3, 4, 5), 1, 11) : (
              local.vpc_cidr_prefix == 16 ? slice(cidrsubnets(local.managed_subnet_az_c, 4, 4, 3, 2, 2, 3, 4), 1, 7) : []
            )
          )
        )
      )
    },
  ]
  eks_managed_worker_subnets = length(var.eks_managed_worker_subnets) > 0 ? var.eks_managed_worker_subnets : local.worker_subnets_calculated
}

module "eks_cluster" {
  source                = "../../_sub/compute/eks-cluster"
  cluster_name          = var.eks_cluster_name
  cluster_version       = var.eks_cluster_version
  deletion_protection   = !var.eks_is_sandbox
  cidr_block            = local.eks_cluster_cidr_block
  cluster_zones         = var.eks_cluster_zones
  cluster_reserved_cidr = local.cluster_reserved_cidr
  log_types             = var.eks_cluster_log_types
  log_retention_days    = var.eks_cluster_log_retention_days
  depends_on            = [module.ipam_pool_query]
}

module "eks_internet_gateway" {
  source = "../../_sub/network/internet-gateway"
  name   = "eks-${var.eks_cluster_name}"
  vpc_id = module.eks_cluster.vpc_id
}

# tflint-ignore: terraform_unused_declarations
data "aws_availability_zones" "available" {
  # At the moment, this is the best way to validate multiple variables against
  # each other:
  # https://github.com/hashicorp/terraform/issues/25609#issuecomment-1136340278
  lifecycle {

    precondition {
      condition = alltrue([
        for sn in local.eks_managed_worker_subnets : startswith(sn.availability_zone, var.aws_region)
      ])
      error_message = "All managed worker subnet availability zones must be within the region specified by var.aws_region."
    }

    precondition {
      condition = alltrue(flatten([
        for name, ng in var.eks_managed_nodegroups : [
          for az in ng.availability_zones : startswith(az, var.aws_region)
        ]
      ]))
      error_message = "All managed node group subnet availability zones must be within the region specified by var.aws_region."
    }

  }
}

module "eks_managed_workers_subnet" {
  source       = "../../_sub/network/vpc-subnet-eks"
  deploy       = length(local.eks_managed_worker_subnets) >= 1 ? true : false
  name         = "eks-${var.eks_cluster_name}-managed-nodes"
  cluster_name = var.eks_cluster_name
  vpc_id       = module.eks_cluster.vpc_id
  subnets      = local.eks_managed_worker_subnets
}

module "eks_workers_keypair" {
  source     = "../../_sub/compute/ec2-keypair"
  name       = "eks-${var.eks_cluster_name}-workers"
  public_key = var.eks_worker_ssh_public_key
}

module "eks_workers_security_group" {
  source                   = "../../_sub/network/security-group-eks-node"
  vpc_id                   = module.eks_cluster.vpc_id
  cluster_name             = var.eks_cluster_name
  autoscale_security_group = module.eks_cluster.autoscale_security_group
  ssh_ip_whitelist         = var.eks_worker_ssh_ip_whitelist
}

# Is actually only IAM at this point
module "eks_workers" {
  source                         = "../../_sub/compute/eks-workers"
  cluster_name                   = var.eks_cluster_name
  cloudwatch_agent_config_bucket = var.eks_worker_cloudwatch_agent_config_deploy ? module.cloudwatch_agent_config_bucket.bucket_name : "none"
  cur_bucket_arn                 = var.eks_worker_cur_bucket_arn
}

module "ssm" {
  source  = "../../_sub/network/vpc-ssm"
  vpc_id  = module.eks_cluster.vpc_id
  subnets = [for sn in module.eks_managed_workers_subnet.subnets : sn.id]
}

# --------------------------------------------------
# NAT Gateway - with or without
# --------------------------------------------------

# NAT Gateway (place in control plane subnet)
module "eks_nat_gateway" {
  source     = "../../_sub/network/nat-gateway"
  count      = var.enable_worker_nat_gateway || var.use_worker_nat_gateway ? length(module.eks_cluster.subnet_ids) : 0
  subnet_id  = module.eks_cluster.subnet_ids[count.index]
  tags       = var.tags
  depends_on = [module.eks_internet_gateway]
}

module "eks_route_table" {
  count                      = var.use_worker_nat_gateway ? 0 : 1
  source                     = "../../_sub/network/route-table"
  name                       = "eks-${var.eks_cluster_name}-subnet"
  vpc_id                     = module.eks_cluster.vpc_id
  gateway_id                 = module.eks_internet_gateway.id
  migrate_vpc_peering_routes = var.migrate_vpc_peering_routes
  tags                       = local.eks_route_table_tags
}

# Control Plane Route Table with NAT Gateway
module "eks_route_table_nat_gateway" {
  count                      = var.use_worker_nat_gateway ? length(module.eks_cluster.subnet_ids) : 0
  source                     = "../../_sub/network/route-table"
  name                       = "eks-${var.eks_cluster_name}-subnet-control-plane-${count.index}"
  vpc_id                     = module.eks_cluster.vpc_id
  gateway_id                 = module.eks_internet_gateway.id
  migrate_vpc_peering_routes = var.migrate_vpc_peering_routes
  tags                       = local.eks_route_table_tags
}

# Worker Node Route Table with NAT Gateway
module "eks_route_table_workers_nat_gateway" {
  count                      = var.use_worker_nat_gateway ? length(module.eks_managed_workers_subnet.subnet_ids) : 0
  source                     = "../../_sub/network/route-table"
  name                       = "eks-${var.eks_cluster_name}-subnet-worker-node-${count.index}"
  vpc_id                     = module.eks_cluster.vpc_id
  nat_gateway_id             = count.index < length(module.eks_nat_gateway) ? module.eks_nat_gateway[count.index].gateway_id : module.eks_nat_gateway[count.index - 1].gateway_id
  migrate_vpc_peering_routes = var.migrate_vpc_peering_routes
  tags                       = local.eks_route_table_tags
}

# Control Plane Route Table Association
module "eks_workers_route_table_assoc" {
  source         = "../../_sub/network/route-table-assoc"
  count          = var.use_worker_nat_gateway ? 0 : 1
  subnet_ids     = module.eks_cluster.subnet_ids
  route_table_id = module.eks_route_table[0].id
}

# Control Plane Route Table Association with NAT Gateway
module "eks_workers_route_table_assoc_nat_gateway" {
  source         = "../../_sub/network/route-table-assoc"
  count          = var.use_worker_nat_gateway ? length(module.eks_cluster.subnet_ids) : 0
  subnet_ids     = tolist([module.eks_cluster.subnet_ids[count.index]])
  route_table_id = module.eks_route_table_nat_gateway[count.index].id
}

# Worker Node Route Table Association
module "eks_managed_workers_route_table_assoc" {
  source         = "../../_sub/network/route-table-assoc"
  count          = var.use_worker_nat_gateway ? 0 : 1
  subnet_ids     = module.eks_managed_workers_subnet.subnet_ids
  route_table_id = module.eks_route_table[0].id
}

module "eks_managed_workers_route_table_assoc_nat_gateway" {
  source         = "../../_sub/network/route-table-assoc"
  count          = var.use_worker_nat_gateway ? length(module.eks_managed_workers_subnet.subnet_ids) : 0
  subnet_ids     = tolist([tostring(module.eks_managed_workers_subnet.subnet_ids[count.index])])
  route_table_id = module.eks_route_table_workers_nat_gateway[count.index].id
}

# --------------------------------------------------
# Managed node groups
# --------------------------------------------------

resource "aws_ssm_parameter" "dockerhub" {
  name  = "/eks/${var.eks_cluster_name}/dockerhub"
  type  = "SecureString"
  value = jsonencode({ username = var.docker_hub_username, password = var.docker_hub_password })
}

module "eks_managed_workers_node_group" {
  source = "../../_sub/compute/eks-nodegroup-managed"

  for_each = var.eks_managed_nodegroups

  cluster_name                              = var.eks_cluster_name
  cluster_version                           = var.eks_cluster_version
  enable_scale_to_zero_after_business_hours = local.enable_scale_to_zero_after_business_hours
  node_role_arn                             = module.eks_workers.worker_role_arn
  security_groups                           = [module.eks_workers_security_group.id]
  scale_to_zero_cron                        = var.eks_worker_scale_to_zero_cron
  ec2_ssh_key                               = module.eks_workers_keypair.key_name
  eks_endpoint                              = module.eks_cluster.eks_endpoint
  eks_certificate_authority                 = module.eks_cluster.eks_certificate_authority
  eks_service_cidr                          = module.eks_cluster.eks_service_cidr
  vpc_cni_prefix_delegation_enabled         = var.eks_addon_vpccni_prefix_delegation_enabled
  worker_inotify_max_user_watches           = var.eks_worker_inotify_max_user_watches

  # Node group variations
  nodegroup_name             = each.key
  ami_id                     = each.value.ami_id
  instance_types             = each.value.instance_types
  use_spot_instances         = each.value.use_spot_instances
  disk_size                  = each.value.disk_size
  disk_type                  = each.value.disk_type
  desired_size_per_subnet    = each.value.desired_size_per_subnet
  gpu_ami                    = each.value.gpu_ami
  taints                     = each.value.taints
  labels                     = each.value.labels
  max_unavailable            = each.value.max_unavailable
  max_unavailable_percentage = each.value.max_unavailable_percentage
  subnet_ids = length(each.value.availability_zones) == 0 ? module.eks_managed_workers_subnet.subnet_ids : [
    for sn in module.eks_managed_workers_subnet.subnets : sn.id if contains(each.value.availability_zones, sn.availability_zone)
  ]
  max_pods               = each.value.max_pods
  kube_reserved_cpu      = each.value.kube_cpu
  kube_reserved_memory   = each.value.kube_memory
  system_reserved_cpu    = each.value.sys_cpu
  system_reserved_memory = each.value.sys_memory

  # Docker Hub credentials
  docker_hub_creds_ssm_path = aws_ssm_parameter.dockerhub.name

  depends_on = [module.eks_cluster]
}

# --------------------------------------------------
# OTHER
# --------------------------------------------------

module "blaster_configmap_bucket" {
  source          = "../../_sub/storage/s3-bucket"
  deploy          = length(var.blaster_configmap_bucket) >= 1 ? true : false
  s3_bucket       = var.blaster_configmap_bucket
  additional_tags = var.blaster_configmap_bucket_tags
}

module "eks_heptio" {
  source                      = "../../_sub/compute/eks-heptio"
  cluster_name                = var.eks_cluster_name
  kubeconfig_path             = local.kubeconfig_path
  eks_endpoint                = module.eks_cluster.eks_endpoint
  eks_certificate_authority   = module.eks_cluster.eks_certificate_authority
  eks_role_arn                = module.eks_workers.worker_role
  blaster_configmap_apply     = length(var.blaster_configmap_bucket) >= 1 ? true : false
  blaster_configmap_s3_bucket = module.blaster_configmap_bucket.bucket_name
  blaster_configmap_key       = "configmap_${module.eks_heptio.cluster_name}_blaster.yml"
  aws_assume_role_arn         = var.aws_assume_role_arn
  eks_k8s_auth_api_version    = var.eks_k8s_auth_api_version
}

module "efs_fs" {
  source                   = "../../_sub/compute/efs-fs"
  name                     = "eks-${var.eks_cluster_name}-efs"
  vpc_id                   = module.eks_cluster.vpc_id
  vpc_subnet_ids           = { ids = module.eks_managed_workers_subnet.subnet_ids }
  automated_backup_enabled = var.efs_automated_backup_enabled
}

module "eks_addons" {
  source                           = "../../_sub/compute/eks-addons"
  depends_on                       = [module.eks_cluster, module.efs_fs]
  cluster_name                     = var.eks_cluster_name
  kubeproxy_version_override       = var.eks_addon_kubeproxy_version_override
  coredns_version_override         = var.eks_addon_coredns_version_override
  vpccni_version_override          = var.eks_addon_vpccni_version_override
  vpccni_prefix_delegation_enabled = var.eks_addon_vpccni_prefix_delegation_enabled
  awsebscsidriver_version_override = var.eks_addon_awsebscsidriver_version_override
  awsefscsidriver_version_override = var.eks_addon_awsefscsidriver_version_override
  podidentity_version_override     = var.eks_addon_podidentity_version_override
  most_recent                      = var.eks_addon_most_recent
  cluster_version                  = var.eks_cluster_version
  eks_openid_connect_provider_url  = module.eks_cluster.eks_openid_connect_provider_url
  efs_fs_id                        = module.efs_fs.id
  ebs_csi_kms_arn                  = var.eks_addon_awsebscsidriver_kms_arn
}

module "k8s_priority_class" {
  source = "../../_sub/compute/k8s-priority-class"
}

module "param_kubeconfig_admin" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/kubeconfig-admin"
  key_description = "Kube config file for initial admin"
  key_value       = module.eks_heptio.kubeconfig_admin
  tags            = var.tags
}

module "param_kubeconfig_saml" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/kubeconfig-saml"
  key_description = "Kube config file for SAML"
  key_value       = module.eks_heptio.kubeconfig_saml
  tags            = var.tags
}

module "eks_s3_public_kubeconfig" {
  source  = "../../_sub/storage/s3-bucket-object"
  deploy  = length(var.eks_public_s3_bucket) >= 1 ? true : false
  bucket  = var.eks_public_s3_bucket
  key     = "kubeconfig/${var.eks_cluster_name}-saml.config"
  content = module.eks_heptio.kubeconfig_saml
  acl     = var.eks_is_sandbox ? "private" : "public-read"
}

# The primary motivation behind this service account is to provide an
# alternative way of authenticating without dependence on ADFS.
module "k8s_service_account" {
  source                    = "../../_sub/compute/k8s-service-account"
  cluster_name              = var.eks_cluster_name
  eks_endpoint              = module.eks_cluster.eks_endpoint
  eks_certificate_authority = module.eks_cluster.eks_certificate_authority
}

module "k8s_service_account_store_secret" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/kubeconfig-deploy-user"
  key_description = "Kube config file for general deployment user"
  key_value       = module.k8s_service_account.deploy_user_kubeconfig
  tags            = var.tags
}

module "cloudwatch_agent_config_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = var.eks_worker_cloudwatch_agent_config_deploy
  s3_bucket = "${var.eks_cluster_name}-cl-agent-config"
}

# --------------------------------------------------
# Cluster access
# --------------------------------------------------

module "k8s_cloudengineer_clusterrole_and_binding" {
  source = "../../_sub/compute/k8s-clusterrole"
  name   = "cloud-engineer"
  rules = [
    {
      api_groups = ["*"]
      resources  = ["*"]
      verbs      = ["create", "get", "list", "watch"]
    },
    {
      api_groups = [""]
      resources  = ["pods", "pods/attach", "pods/exec", "pods/portforward", "pods/proxy"]
      verbs      = ["*"]
    },
    {
      api_groups = [""]
      resources  = ["nodes"]
      verbs      = ["patch"]
    }
  ]
}

# --------------------------------------------------
# AWS IAM Open ID Connect Provider
# --------------------------------------------------
module "aws_iam_oidc_provider" {
  source                          = "../../_sub/security/iam-oidc-provider"
  eks_openid_connect_provider_url = module.eks_cluster.eks_openid_connect_provider_url
  eks_cluster_name                = var.eks_cluster_name
}


# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "inactivity" {
  count               = var.eks_is_sandbox ? 1 : 0
  alarm_name          = "inactivity"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 24
  datapoints_to_alarm = 24
  threshold           = 0
  alarm_description   = "Detects whether the account has any targets in its target groups. If not, the cluster is deemed inactive and some resources maybe automatically cleaned up to avoid excess charges."
  actions_enabled     = true
  alarm_actions       = []

  # Ideally, we would like to detect inactivity over a longer range of time,
  # but CloudWatch's evaluation period is limited to 1 day. We use this
  # workaround to avoid cleaning up resources based on normal inactivity over a
  # weekend.
  metric_query {
    id          = "e1"
    expression  = "IF(DAY(m1) < 6, m1, 10)"
    label       = "Inactivity excluding weekend"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "ResourceCount"
      namespace   = "AWS/Usage"
      period      = 3600 # an hour
      stat        = "Average"
      dimensions = {
        Type     = "Resource"
        Resource = "TargetsPerTargetGroupPerRegion"
        Service  = "Elastic Load Balancing"
        Class    = "None"
      }
    }
  }
}

module "eks_inactivity_cleanup" {
  count                = local.enable_inactivity_cleanup ? 1 : 0
  source               = "../../_sub/compute/eks-inactivity-cleanup"
  eks_cluster_name     = var.eks_cluster_name
  eks_cluster_arn      = module.eks_cluster.eks_cluster_arn
  inactivity_alarm_arn = aws_cloudwatch_metric_alarm.inactivity[0].arn
}

# --------------------------------------------------
# GPU workloads
# --------------------------------------------------

module "eks_version_endpoint" {
  count           = var.secure_eks_version_endpoint ? 1 : 0
  source          = "../../_sub/security/eks-version-endpoint"
  kubeconfig_path = local.kubeconfig_path
  depends_on      = [module.eks_heptio]
}

# --------------------------------------------------
# Karpenter prerequisites (not Karpenter itself)
# --------------------------------------------------

module "karpenter" {
  source                        = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                       = "21.3.1"
  create                        = true
  cluster_name                  = var.eks_cluster_name
  create_access_entry           = true
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "karpenter-${var.eks_cluster_name}"
  create_iam_role               = true
  namespace                     = "karpenter"
  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # Enable SSM core functionality
  }
  depends_on = [module.eks_cluster]
}

# Required service linked role for spot instances (in some accounts this is already provisioned)
resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}

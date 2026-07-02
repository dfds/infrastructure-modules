# --------------------------------------------------
# Flux CD Bootstrap
# --------------------------------------------------

resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

data "github_branch" "flux_branch" {
  repository = var.repository_name
  branch     = var.branch
}

resource "github_repository_deploy_key" "main" {
  title      = "flux-${var.cluster_name}-readonly"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = false
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.main]
  path       = local.cluster_target_path
  version    = var.release_tag
  kustomization_override = templatefile("${path.module}/values/flux-system-patch.yaml", {
    src_ctrl_arn = module.source_controller_irsa.arn
  })
}


# --------------------------------------------------
# Flux CD Monitoring
# --------------------------------------------------

resource "github_repository_file" "flux_monitoring_config_path" {
  count               = var.enable_monitoring ? 1 : 0
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/${local.app_install_name}.yaml"
  content             = jsonencode(local.flux_monitoring)
  overwrite_on_create = true
}


# --------------------------------------------------
# Flux CD Apps
# --------------------------------------------------

resource "github_repository_file" "platform_apps_init" {
  repository = var.repository_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_target_path}/platform-apps.yaml"
  content = templatefile("${path.module}/values/platform-apps.yaml", {
    gitops_apps_repo_url = var.gitops_apps_repo_url,
    gitops_apps_repo_ref = var.gitops_apps_repo_ref,
    gitops_apps_repo_tag = var.gitops_apps_repo_tag,
    prune                = var.prune,
  })
  overwrite_on_create = true
}

resource "github_repository_file" "custom_kustomization" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/custom.yaml"
  content             = local.custom_kustomization_yaml
  overwrite_on_create = true
}

resource "github_repository_file" "custom_folder" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "platform-apps/${var.cluster_name}/custom/README.md"
  content             = local.custom_folder_readme
  overwrite_on_create = true
}

# --------------------------------------------------
# Flux CD Multi-tenancy
# --------------------------------------------------

resource "github_repository_file" "tenants" {
  count      = length(var.tenants) > 0 ? 1 : 0
  repository = var.repository_name
  branch     = data.github_branch.flux_branch.branch
  file       = "${local.cluster_target_path}/tenants.yaml"
  content = templatefile("${path.module}/values/tenants.yaml", {
    tenants      = var.tenants
    cluster_name = var.cluster_name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "tenant_rbac" {
  for_each   = { for tenant in var.tenants : tenant.namespace => tenant }
  repository = var.repository_name
  branch     = data.github_branch.flux_branch.branch
  file       = "tenants/${var.cluster_name}/base/${each.value.namespace}/rbac.yaml"
  content = templatefile("${path.module}/values/rbac.yaml", {
    namespace = each.value.namespace
  })
  overwrite_on_create = true
}

resource "github_repository_file" "tenant_kustomization" {
  for_each   = { for tenant in var.tenants : tenant.namespace => tenant }
  repository = var.repository_name
  branch     = data.github_branch.flux_branch.branch
  file       = "tenants/${var.cluster_name}/base/${each.value.namespace}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    namespace = each.value.namespace
  })
  overwrite_on_create = true
}

resource "github_repository_file" "tenant_sync" {
  for_each   = { for tenant in var.tenants : tenant.namespace => tenant }
  repository = var.repository_name
  branch     = data.github_branch.flux_branch.branch
  file       = "tenants/${var.cluster_name}/base/${each.value.namespace}/sync.yaml"
  content = templatefile("${path.module}/values/sync.yaml", {
    namespace = each.value.namespace
    repositories = [for k, v in each.value.repositories :
      merge(v, { name = element((split("/", v.url)), length((split("/", v.url))) - 1) })
    ]
  })
  overwrite_on_create = true
}

module "source_controller_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.6.1"
  name = "${var.cluster_name}-fluxcd-source-controller-ecr-reader"
  use_name_prefix = false
  oidc_providers = {
    this = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${trim(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")}"
      namespace_service_accounts = ["flux-system:source-controller"]
    }
  }
  policies = {
    ecr-readonly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}

# Allow Flux to pull new images and tag through ECR pull through cache
data "aws_iam_policy_document" "allow_ecr_pull_through_cache" {
  statement {
    sid = "ECRPullThroughCache"
    effect = "Allow"
    actions   = ["ecr:BatchImportUpstreamImage"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_ecr_pull_through_cache" {
  name = "fluxcd-source-controller-${var.cluster_name}-ecr-pull-through-cache"
  role = module.source_controller_irsa.name
  policy = data.aws_iam_policy_document.allow_ecr_pull_through_cache.json
}
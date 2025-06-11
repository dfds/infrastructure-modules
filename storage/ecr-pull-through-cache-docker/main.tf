module "pull_through_cache_for_docker" {
  source                  = "../../_sub/storage/ecr-pull-through-cache"
  secret_name             = "ecr-pullthroughcache/docker-hub"
  ecr_repository_prefix   = "docker-hub"
  upstream_registry_url   = "registry-1.docker.io"
  recovery_window_in_days = 7
  cache_lifecycle_days    = 7
  username                = var.docker_username
  token                   = var.docker_token
  aws_org_id              = var.aws_org_id
  aws_region              = var.aws_region
}

# --------------------------------------------------
# Cluster
# --------------------------------------------------

# Legacy, to be decommisioned
output "eks_cluster_vpc_id" {
  value = module.eks_cluster.vpc_id
}

# Legacy, to be decommisioned
output "eks_cluster_subnet_ids" {
  value = module.eks_cluster.subnet_ids
}

output "kubeconfig_path" {
  value = local.kubeconfig_path
}


output "eks_openid_connect_provider_url" {
  value = module.eks_cluster.eks_openid_connect_provider_url
}


# --------------------------------------------------
# Node groups/Workers
# --------------------------------------------------

output "eks_worker_subnet_ids" {
  value = length(module.eks_workers_subnet.subnet_ids) > 0 ? module.eks_workers_subnet.subnet_ids : module.eks_managed_workers_subnet.subnet_ids
}

output "eks_workers_security_group_id" {
  value = module.eks_workers_security_group.id
}

output "eks_worker_role_id" {
  value = module.eks_workers.worker_role_id
}

output "eks_worker_autoscaling_group_ids" {
  value = flatten([
    module.eks_nodegroup1_workers.autoscaling_group_id,
    module.eks_nodegroup2_workers.autoscaling_group_id,
    [for m in module.eks_managed_workers_node_group : m.autoscaling_group_id],
  ])
}

output "eks_cluster_nodes_sg_id" {
  value = module.eks_workers_security_group.id
}

output "eks_worker_autoscaling_group_container_runtimes" {
  value = flatten([
    module.eks_nodegroup1_workers.container_runtime,
    module.eks_nodegroup2_workers.container_runtime,
    [for m in module.eks_managed_workers_node_group : m.container_runtime],
  ])
}

# --------------------------------------------------
# Misc
# --------------------------------------------------

output "blaster_configmap_bucket" {
  value = module.blaster_configmap_bucket.bucket_name
}

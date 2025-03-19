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

output "eks_cluster_arn" {
  value = module.eks_cluster.eks_cluster_arn
}

output "eks_is_sandbox" {
  value = var.eks_is_sandbox
}

output "eks_inactivity_alarm_arn" {
  value = try(aws_cloudwatch_metric_alarm.inactivity[0].arn, null)
}

# --------------------------------------------------
# Node groups/Workers
# --------------------------------------------------

output "eks_worker_subnet_ids" {
  value = module.eks_managed_workers_subnet.subnet_ids
}

output "eks_workers_security_group_id" {
  value = module.eks_workers_security_group.id
}

output "eks_worker_role_id" {
  value = module.eks_workers.worker_role_id
}

output "eks_worker_autoscaling_group_ids" {
  value = flatten([for m in module.eks_managed_workers_node_group : m.autoscaling_group_id])
}

output "eks_cluster_nodes_sg_id" {
  value = module.eks_workers_security_group.id
}

# --------------------------------------------------
# Misc
# --------------------------------------------------

output "blaster_configmap_bucket" {
  value = module.blaster_configmap_bucket.bucket_name
}

output "eks_control_subnet_ids" {
  value = module.eks_cluster.subnet_ids
}

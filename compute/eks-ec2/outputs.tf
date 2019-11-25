# # --------------------------------------------------
# # DNS
# # --------------------------------------------------

# output "workload_dns_zone_name" {
#     value = "${var.workload_dns_zone_name}"
# }

# output "workload_dns_zone_id" {
#     value = "${local.workload_dns_zone_id}"
# }

# output "core_dns_zone_name" {
#     value = "${local.core_dns_zone_name}"
# }

# output "core_dns_zone_id" {
#     value = "${local.core_dns_zone_id}"
# }

# --------------------------------------------------
# EKS
# --------------------------------------------------

output "eks_worker_role_id" {
  value = "${module.eks_workers.worker_role_id}"
}

output "eks_worker_autoscaling_group_id" {
  value = "${module.eks_workers.autoscaling_group_id}"
}

output "eks_cluster_nodes_sg_id" {
  value = "${module.eks_workers.nodes_sg_id}"
}

output "eks_cluster_vpc_id" {
  value = "${module.eks_cluster.vpc_id}"
}

output "eks_cluster_subnet_ids" {
  value = "${module.eks_cluster.subnet_ids}"
}

output "blaster_configmap_bucket" {
  value = "${module.blaster_configmap_bucket.bucket_name}"
}
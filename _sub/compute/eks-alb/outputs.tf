output "alb_fqdn" {
  value = "${element(concat(aws_lb.traefik.*.dns_name, list("")), 0)}"
}

# output "dbg_subnet_ids" {
#   value = "${data.terraform_remote_state.cluster.eks_cluster_subnet_ids}"
# }
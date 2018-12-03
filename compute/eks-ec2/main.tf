provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    version = "~> 1.40"

    assume_role {
        role_arn = "${var.assume_role_arn}"
    }

}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

module "eks_cluster" {
    source = "../../_sub/compute/eks-cluster"
    cluster_name = "${var.cluster_name}"
}

module "eks_workers" {
    source = "../../_sub/compute/eks-workers"
    cluster_name = "${var.cluster_name}"
    autoscale_security_group = "${module.eks_cluster.autoscale_security_group}"
    worker_instance_max_count = "${var.worker_instance_max_count}"
    worker_instance_min_count = "${var.worker_instance_min_count}"
    worker_instance_type = "${var.worker_instance_type}"
    vpc_id = "${module.eks_cluster.vpc_id}"
    subnet_ids = "${module.eks_cluster.subnet_ids}"
    eks_endpoint = "${module.eks_cluster.eks_endpoint}"
    eks_certificate_authority = "${module.eks_cluster.eks_certificate_authority}"
}

module "eks_heptio" {
    source = "../../_sub/compute/eks-heptio"
    cluster_name = "${var.cluster_name}"
    eks_endpoint = "${module.eks_cluster.eks_endpoint}"
    eks_certificate_authority = "${module.eks_cluster.eks_certificate_authority}"
    eks_role_arn = "${module.eks_workers.worker_role}"
    assume_role_arn = "${var.assume_role_arn}"
}
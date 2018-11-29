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
}

# module "eks_heptio" {
#     source = "../../_sub/compute/eks-heptio"
#     cluster_name = "${var.cluster_name}"
# }
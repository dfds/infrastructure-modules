# data "external" "heptio_authenticator_aws" {
#   program = ["/bin/sh", "-c", "./authenticator.sh"]

#   query {
#     cluster_name = "${var.cluster_name}"
#   }

# }

# provider "kubernetes" {
#   #host                   = "${aws_eks_cluster.demo.endpoint}"
#   #cluster_ca_certificate = "${base64decode(aws_eks_cluster.demo.certificate_authority.0.data)}"
#   token                  = "${data.external.heptio_authenticator_aws.result.token}"
#   load_config_file       = true
# }

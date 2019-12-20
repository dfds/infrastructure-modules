# Since Kubernetes provider does not seem to be used, is this even needed?
# data "external" "heptio_authenticator_aws" {
#   program = ["/bin/sh", "-c", "./authenticator.sh"]
#   query {
#     cluster_name = "${var.cluster_name}"
#   }
# }
# Kubernetes provider not being used at all in this sub?
# provider "kubernetes" {
#   config_path      = "${local_file.kubeconfig.filename}"
#   token            = "${data.external.heptio_authenticator_aws.result.token}"
#   load_config_file = true
# }

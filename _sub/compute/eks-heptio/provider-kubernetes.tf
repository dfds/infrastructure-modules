data "external" "heptio_authenticator_aws" {
  program = ["/bin/sh", "-c", "./authenticator.sh"]

  query {
    cluster_name = "${var.cluster_name}"
  }

}

provider "kubernetes" {
  config_path = "${local_file.kubeconfig.filename}"
  token                  = "${data.external.heptio_authenticator_aws.result.token}"
  load_config_file       = true
}

provider "helm" {
    kubernetes {
        config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
    }
}

resource "null_resource" "init_helm" {

  provisioner "local-exec" {
        command = "helm init --client-only"
    }
  
}
resource "helm_repository" "servicecatalog" {
    name = "servicecatalog"
    url  = "https://svc-catalog-charts.storage.googleapis.com"

    depends_on = 
        [
            "null_resource.init_helm"
        ]
}

resource "helm_repository" "aws-sb" {
    name = "aws-sb"
    url  = "https://awsservicebroker.s3.amazonaws.com/charts"

    depends_on = 
        [
            "null_resource.init_helm"
        ]
}

resource "helm_release" "service-catalog" {
    name        = "catalog"
    repository  = "${helm_repository.servicecatalog.metadata.0.name}"
    namespace   = "catalog"
    chart       = "catalog"
}

resource "helm_release" "service-broker" {
    name        = "aws-servicebroker"
    repository  = "${helm_repository.aws-sb.metadata.0.name}"
    namespace   = "aws-sb"
    chart       = "aws-servicebroker"
    version     = "1.0.0-beta.3"
    set {
        name    = "aws.region"
        value   = "${var.aws_region}"
    }
    set {
        name    = "aws.tablename"
        value   = "${var.table_name}-${var.cluster_name}"
    }
    set {
        name    = "brokerconfig.brokerid"
        value   = "${var.cluster_name}sb"
    }
    set_string {
        name    = "aws.targetaccountid"
        value   = "${var.workload_account_id}"
    }
}


# image: awsservicebroker/aws-servicebroker:beta
# imagePullPolicy: Always
# authenticate: true
# tls:
#   cert:
#   key:
# deployClusterServiceBroker: true
# aws:
#   region: us-east-1
#   bucket: awsservicebroker
#   key: templates/latest
#   s3region: us-east-1
#   tablename: awssb
#   accesskeyid: ""
#   secretkey: ""
#   targetaccountid: ""
#   targetrolename: ""
#   vpcid: ""
# brokerconfig:
#   verbosity: 10
#   brokerid: awsservicebroker
#   prescribeoverrides: true
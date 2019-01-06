provider "helm" {
    kubernetes {
        config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
    }
}

resource "helm_repository" "svc-cat" {
    name = "svc-cat"
    url  = "https://svc-catalog-charts.storage.googleapis.com"
}

resource "helm_repository" "aws-sb" {
    name = "aws-sb"
    url  = "https://awsservicebroker.s3.amazonaws.com/charts"
}

resource "helm_release" "service-catalog" {
    name        = "catalog"
    repository  = "${helm_repository.svc-cat.metadata.0.name}"
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
        value   = "awsbroker-${var.cluster_name}"
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
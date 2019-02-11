resource "helm_release" "harbor" {
  name      = "harbor-registry"
  namespace = "${var.namespace}"
  chart     = "${path.module}/harbor-chart"
  version   = "1.7.1"

  force_update = true

  set {
    name  = "expose.type"
    value = "ingress"
  }

  set {
    name  = "expose.ingress.hosts.core"
    value = "${var.registry_endpoint}"
  }

  set {
    name  = "expose.ingress.hosts.notary"
    value = "${var.notary_endpoint}"
  }

  set {
    name  = "externalURL"
    value = "${var.registry_endpoint_external_url}"
  }

  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "persistence.resourcePolicy"
    value = ""
  }

  set {
    name  = "persistence.imageChartStorage.type"
    value = "s3"
  }

  set {
    name  = "persistence.imageChartStorage.s3.region"
    value = "${var.s3_region}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.accesskey"
    value = "${var.harbor_s3_acces_key}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.secretkey"
    value = "${var.harbor_s3_secret_key}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.bucket"
    value = "${var.bucket_name}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.regionendpoint"
    value = "${var.s3_region_endpoint}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.storageclass"
    value = "STANDARD"
  }

  set {
    name  = "nginx.image.repository"
    value = "goharbor/nginx-photon"
  }

  set {
    name  = "nginx.image.tag"
    value = "v1.7.1"
  }

  set {
    name  = "portal.image.repository"
    value = "goharbor/harbor-portal"
  }

  set {
    name  = "portal.image.tag"
    value = "v1.7.1"
  }

  set {
    name  = "core.image.repository"
    value = "goharbor/harbor-core"
  }

  set {
    name  = "core.image.tag"
    value = "v1.7.1"
  }

  set {
    name  = "adminserver.image.repository"
    value = "goharbor/harbor-adminserver"
  }

  set {
    name  = "adminserver.image.tag"
    value = "v1.7.1"
  }

  set {
    name  = "jobservice.image.repository"
    value = "goharbor/harbor-jobservice"
  }

  set {
    name  = "jobservice.image.tag"
    value = "v1.7.1"
  }

  set {
    name  = "registry.registry.image.repository"
    value = "goharbor/registry-photon"
  }

  set {
    name  = "registry.registry.image.tag"
    value = "v2.6.2-v1.7.1"
  }

  set {
    name  = "registry.controller.image.repository"
    value = "goharbor/harbor-registryctl"
  }

  set {
    name  = "registry.controller.image.tag"
    value = "v1.7.1"
  }

  set {
    name  = "chartmuseum.enabled"
    value = true
  }

  set {
    name  = "chartmuseum.image.repository"
    value = "goharbor/chartmuseum-photon"
  }

  set {
    name  = "chartmuseum.image.tag"
    value = "v0.7.1-v1.7.1"
  }

  set {
    name  = "clair.enabled"
    value = true
  }

  set {
    name  = "clair.image.repository"
    value = "goharbor/clair-photon"
  }

  set {
    name  = "clair.image.tag"
    value = "v2.0.7-v1.7.1"
  }

  set {
    name  = "notary.enabled"
    value = true
  }

  set {
    name  = "notary.server.image.repository"
    value = "goharbor/notary-server-photon"
  }

  set {
    name  = "notary.server.image.tag"
    value = "v0.6.1-v1.7.1"
  }

  set {
    name  = "notary.signer.image.repository"
    value = "goharbor/notary-signer-photon"
  }

  set {
    name  = "notary.signer.image.tag"
    value = "v0.6.1-v1.7.1"
  }

  set {
    name  = "database.type"
    value = "external"
  }

  set {
    name  = "database.external.host"
    value = "${var.db_server_host}"
  }

  set {
    name  = "database.external.port"
    value = "${var.db_server_port}"
  }

  set {
    name  = "database.external.username"
    value = "${var.db_server_username}"
  }

  set {
    name  = "database.external.password"
    value = "${var.db_server_password}"
  }

  set {
    name  = "database.external.coreDatabase"
    value = "registry"
  }

  set {
    name  = "database.external.clairDatabase"
    value = "clair"
  }

  set {
    name  = "database.external.notaryServerDatabase"
    value = "notary_server"
  }

  set {
    name  = "database.external.notarySignerDatabase"
    value = "notary_signer"
  }

  set {
    name  = "redis.type"
    value = "internal"
  }

  set {
    name  = "redis.internal.image.repository"
    value = "goharbor/redis-photon"
  }

  set {
    name  = "redis.internal.image.tag"
    value = "v1.7.1"
  }

  #--------------------------------------------------------------#
  # Note: A combinitation of set and raw yaml values override was need to get this to work
  #--------------------------------------------------------------#
  values = [<<EOF
    expose:
        annotations:
            kubernetes.io/ingress.class: traefik
EOF
  ]
}

# resource "null_resource" "annotate_namespace" {
#   triggers {
#     build_number = "${timestamp()}"
#   }


#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} annotate --overwrite ns aws-sb iam.amazonaws.com/permitted='dfds-container-registry-pascal-access-test'"
#   }


#   depends_on = ["helm_release.harbor"]
# }


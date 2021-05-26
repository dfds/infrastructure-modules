locals {
    label_k8s-app           = var.deploy_name
    http_name               = "http"
    http_port               = 80
    admin_name              = "admin"
    admin_port              = 8080
    dashboard_secret_name = "${var.deploy_name}-basic-auth"
    dashboard_ingress_annotations   = {
        "kubernetes.io/ingress.class" = "traefik"
        "traefik.ingress.kubernetes.io/auth-type" = "basic"
        "traefik.ingress.kubernetes.io/auth-secret" = local.dashboard_secret_name
    }
    dashboard_ingress_name = "${var.deploy_name}-dashboard"
    dashboard_ingress_labels = {
        "name" = local.dashboard_ingress_name
    }
}

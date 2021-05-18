locals {
    label_k8s-app           = var.deploy_name
    http_name               = "http"
    http_port               = 80
    admin_name              = "admin"
    admin_port              = 8080
    dashboard_ingress_annotations   = {
        "kubernetes.io/ingress.class" = "traefik"
        "traefik.ingress.kubernetes.io/auth-type" = "basic"
        "traefik.ingress.kubernetes.io/auth-secret" = kubernetes_secret.secret.metadata[0].name
    }
}

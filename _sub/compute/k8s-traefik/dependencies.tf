locals {
    label_k8s-app  = var.deploy_name
    http_name      = "http"
    http_port      = 80
    http_nodeport  = 30000
    admin_name     = "admin"
    admin_port     = 8080
    admin_nodeport = 30001
}
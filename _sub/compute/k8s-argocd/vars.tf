variable "deploy" {
  default = true
}
variable "namespace" {
  description = "Speficy in which namespace ArgoCD application should run."
  type = "string"
}

variable "oidc_issuer" {
  description = "The ID of the OpenId Connect issuer."
  type = "string"
}

variable "oidc_client_id" {
  description = "The ID of the OpenId Connect client."
  type = "string"
}

variable "oidc_client_secret" {
  description = "The secret of the OpenId Connect client."
  type = "string"
}

variable "external_url" {
  description = "The full url of ArgoCD application. Example: https://myargoapp.com."
  type = "string"
}

variable "host_url" {
  description = "Host name of ArgoCD application. Example myargoapp.com."
  type = "string"
}

variable "grpc_host_url" {
  description = "GRPC endpoint of ArgoCD application. Example grpc.myargoapp.com."
  type = "string"
}

variable "argo_app_image" {
  description = "Image name for ArgoCD application."
  type = "string"
}

variable "cluster_name" {
  description ="Cluster Name"
  type = "string"
}
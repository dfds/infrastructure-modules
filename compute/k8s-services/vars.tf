#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "cluster_name" {
  type = "string"
}

variable "traefik_k8s_name" {}
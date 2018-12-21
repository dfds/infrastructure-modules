#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "cluster_name" {
  type = "string"
}

variable "traefik_k8s_name" {}
variable "namespace" {
  description = "Namespace where flux daemon should run."
}
variable "config_git_repo_url" {
  description = "Git url for the repo that holds service kubernetes manifests."
}

variable "config_git_repo_branch" {
  description = "Git branch to use."
}


variable "namespace" {
  description = "Namespace where flux daemon should run."
}
variable "config_git_repo_url" {
  description = "Git url for the repo that holds service kubernetes manifests."
}

variable "config_git_repo_branch" {
  description = "Git branch to use."
}

variable "config_git_repo_label" {
  description = "Git branch to use."
}

variable "config_git_private_key" {
  description = "Private key to access git repo."
}

variable "cluster_name" {
  description = "Name of cluster"  
}

variable "docker_registry_endpoint" {
  description = "The FQDN of docker registry server. A valid enpoint could be yourdomain.com"
}

variable "docker_registry_username" {
  description = "Username for the user that enables Flux to read the docker registry information."
}

variable "docker_registry_password" {
  description = "Password for the user that enables Flux to read the docker registry information."
}


variable "docker_registry_email" {
  description = "Email address for the user that enables Flux to read the docker registry information."
}
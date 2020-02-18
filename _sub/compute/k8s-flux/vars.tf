variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
  description = "Name of cluster"
}

variable "namespace" {
  description = "Namespace where flux daemon should run."
}

variable "git_url" {
  description = "Git url for the repo that holds service kubernetes manifests."
}

variable "git_branch" {
  description = "Git branch to use."
}

variable "git_label" {
  description = "Git branch to use."
}

variable "git_key" {
  description = "Private key to access git repo."
}

variable "registry_endpoint" {
  description = "The FQDN of docker registry server. A valid enpoint could be yourdomain.com"
}

variable "registry_username" {
  description = "Username for the user that enables Flux to read the docker registry information."
}

variable "registry_password" {
  description = "Password for the user that enables Flux to read the docker registry information."
}

variable "registry_email" {
  description = "Email address for the user that enables Flux to read the docker registry information."
}


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



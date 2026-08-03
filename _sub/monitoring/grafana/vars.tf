variable "github_owner" {
  type        = string
  description = "Name of the Github owner (previously: organization)"
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
}

variable "cluster_name" {
  type = string
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "gitops_apps_repo_url" {
  type        = string
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  description = "The default branch or tag for your GitOps manifests"
}

variable "agent_resource_memory" {
  type        = string
  description = "Set resource memory request and limits on Grafana Agent container"
}

variable "agent_replicas" {
  type        = number
  description = "How many replicas to run Grafana Agent with"
}

variable "storage_size" {
  type        = string
  description = <<-EOT
    Storage size for Grafana Persistent Volume.
    Please note that it is not possible to directly change this value after the initial deployment,
    so it should be set with care. If you want to change it, you need to first delete the Grafana release and then apply it again with the new value. Default: 5Gi
    Alternatively, you can use kubectl to edit the PersistentVolumeClaim created for Grafana and change the storage size there,
    but this approach is not recommended as it may cause issues with the state of the release in Helm.
  EOT
  default     = "5Gi"
}

variable "grafana_stack" {
  type        = string
  description = "The Grafana Cloud stack to use"
}

variable "onepassword_access_parameter_store_arn" {
  type        = string
  description = "The ARN of the SSM parameter for Grafana 1password token"
}

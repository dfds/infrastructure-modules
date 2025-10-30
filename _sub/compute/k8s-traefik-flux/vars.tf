variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "traefik"
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "traefik"
}

variable "replicas" {
  description = "The number of Traefik pods to spawn"
  type        = number
}

variable "http_nodeport" {
  description = "Nodeport used by ALB's to connect to the Traefik instance"
  type        = number
}

variable "admin_nodeport" {
  description = "Nodeport used by ALB's to connect to the Traefik instance admin page"
  type        = number
}

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
  default     = null
}

variable "helm_chart_version" {
  type        = string
  description = "The version of the Traefik v2 Helm Chart that should be used"
  default     = ""
}

variable "additional_args" {
  type        = list(any)
  description = "Pass arguments to the additionalArguments node in the Traefik Helm chart"
  default     = ["--metrics.prometheus"]
}

variable "dashboard_ingress_host" {
  type        = string
  description = "The alb auth dns name for accessing Traefik."
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "enable_certificate_resolver" {
  type = bool
  default = false
  description = "Enable the use of a certificate resolver (e.g. for Let's Encrypt)"
}

variable "certificate_resolver_email" {
  type = string
  default = ""
  description = "Email address to use for the certificate resolver registration (e.g. Let's Encrypt)"
}

variable "certificate_resolver_storage_enabled" {
  type = bool
  default = false
  description = "Enable persistent storage for the certificate resolver (e.g. for Let's Encrypt)"
}
variable "certificate_resolver_storage_class" {
  type = string
  default = "gp2"
  description = "Storage class to use for the certificate resolver persistent storage (e.g. for Let's Encrypt)"
}
variable "certificate_resolver_storage_access_mode" {
  type = string
  default = "ReadWriteOnce"
  description = "Access mode to use for the certificate resolver persistent storage (e.g. for Let's Encrypt)"
}
variable "certificate_resolver_storage_size" {
  type = string
  default = "128Mi"
  description = "Size of the persistent storage to use for the certificate resolver (e.g. for Let's Encrypt)"
}

variable "certficate_resolver_args" {
  type = list(any)
  default = []
  description = "Additional arguments to configure the certificate resolver (e.g. for Let's Encrypt)"
}

variable "certificate_resolver_is_staging" {
  type = bool
  default = false
  description = "Use the staging environment for the certificate resolver (e.g. for Let's Encrypt)"
}
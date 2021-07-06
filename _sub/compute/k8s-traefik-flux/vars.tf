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

variable "kubeconfig_path" {
  type        = string
  description = "The path to the kubeconfig file."
  default     = null
}

variable "fallback" {
  type        = bool
  description = "Should a fallback ingressroute be created that routes traffic to Traefik v1"
  default     = true
}

variable "fallback_rule_match" {
  type        = string
  description = "The rule match of hosts, regexp and/or paths to serve through a fallback ingressroute"
  default     = "HostRegexp(`{domain:.+}`)"
}

variable "fallback_ingressroute_name" {
  type        = string
  description = "The name for the ingressroute used for fallback"
  default     = "traefik-fallback-to-v1-ingress"
}

variable "fallback_ingressroute_priority" {
  type        = number
  description = "IngressRoute priority. Should be a low number, but preferably not lower than 2"
  default     = 2
}

variable "fallback_svc_namespace" {
  type        = string
  description = "The service used for fallback ingress is stored in which namespace"
  default     = "kube-system"
}

variable "fallback_svc_name" {
  type        = string
  description = "The service name used for fallback ingress"
  default     = "traefik"
}

variable "fallback_svc_port" {
  type        = number
  description = "The service port used for fallback ingress"
  default     = 80
}

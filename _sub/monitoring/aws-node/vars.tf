variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "app_name" {
  type    = string
  default = "aws-node"
}

variable "svc_name" {
  type    = string
  default = null
}

variable "svc_type" {
  type    = string
  default = "ClusterIP"
}

variable "internal_traffic_policy" {
  type    = string
  default = "Cluster"
}

variable "ip_families" {
  type    = list(string)
  default = ["IPv4"]
}

variable "ip_family_policy" {
  type    = string
  default = "SingleStack"
}

variable "session_affinity" {
  type    = string
  default = "None"
}

variable "port_name" {
  type    = string
  default = "metrics"
}

variable "protocol" {
  type    = string
  default = "TCP"
}

variable "port" {
  type    = number
  default = 61678
}

variable "target_port" {
  type    = number
  default = 61678
}

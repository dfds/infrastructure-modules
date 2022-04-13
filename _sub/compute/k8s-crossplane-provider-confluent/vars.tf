variable "email" {
  type = string
  description = "Confluent global admin account email"
}

variable "password" {
  type = string
  description = "Confluent global admin account password"
  sensitive = true
}

variable "namespace" {
  type = string
  description = "Namespace to deploy in"
}
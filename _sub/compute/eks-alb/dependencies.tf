locals {
  traefik_deployment_defaults = {
    ports = {
      web = 8000 # this is default web port for Traefik Helm Chart
      admin = 8080 # this is default admin port for Traefik Helm Chart
    }
    path = "/ping" # this is default health check path for Traefik Helm Chart
  }
}
# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//compute/k8s-services"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../cluster", "../svc-prereqs"]
}


inputs = {

  # --------------------------------------------------
  # EKS
  # --------------------------------------------------

  eks_cluster_name = "qa14"


  # --------------------------------------------------
  # Traefik
  # --------------------------------------------------

  traefik_deploy      = true
  traefik_version     = "1.7.19"
  traefik_deploy_name = "traefik"

  traefik_alb_auth_deploy = true # triggers Azure App registration
  traefik_alb_anon_deploy = true
  # traefik_alb_auth_core_alias = ["qa-alias1.dfds.cloud", "qa-alias2.dfds.cloud"]
  traefik_alb_auth_core_alias = []

  traefik_nlb_deploy      = false # needed a.o. for Argo CLI
  traefik_nlb_cidr_blocks = ["0.0.0.0/0"]


  # --------------------------------------------------
  # KIAM
  # --------------------------------------------------

  kiam_deploy = true


  # --------------------------------------------------
  # Blaster
  # Requires: KIAM
  # --------------------------------------------------

  blaster_deploy           = true
  blaster_configmap_bucket = ""


  # --------------------------------------------------
  # Service Broker
  # Requires: KIAM
  # --------------------------------------------------

  servicebroker_deploy = false


  # --------------------------------------------------
  # Argo
  # --------------------------------------------------

  argocd_deploy             = false
  argocd_default_repository = ""


  # --------------------------------------------------
  # Harbor
  # --------------------------------------------------

  harbor_deploy = false

  harbor_k8s_namespace             = "harbor"
  harbor_db_storage_size           = 5
  harbor_db_instance_size          = "db.t3.small"
  harbor_db_server_username        = "harbor"
  harbor_postgresdb_engine_version = "10.6"


  # --------------------------------------------------
  # Flux
  # --------------------------------------------------

  flux_deploy = false

  flux_k8s_namespace = "flux"

  flux_git_url        = "git@github.com:dfds/infrastructure-config"
  flux_git_branch     = "raras"
  flux_git_label      = "raras"
  flux_git_key_base64 = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBMVVaQldPa00rK084YjdmMnpteDBRS0pOS2I5MmFibjN6bVBFODV5RWMrVFpVTnZECjYzQ3ZZWGtURVAyMHNrb2d3U0hRTlNnb0NqSXU0NTBpaDFxeEhBd01UTXNzMFdkQnFWSUR3YWxUQ3BRSTcvRHoKS2VON3BTd3BuZ1B5clpoUzVmZG1rYmRFdEdsSEhUcGhHZFpmN0FFY3BLS1I5anBzbWcrOFVzYjdVNWcrRmZYUApOdDJTTTY2cEErZ3JuOVdxVU5WTVBMOUhZcXhVb2VUT2FFVlRrc0FHRk1nbVo5T2E2SjJNSFFReW8xMEJGMlhjCndYTWhGY29VVnVibVZZZUVKSGtPY24vaVUrQ0xzajdBVTB5TEhzL0p2a0RrUk0vTkJMZVZLa1dOc0FlRUxydHUKTXVlRVc4c3h2TlJqc09FMWlXY1dmN1BFRFlvL3dCdWhqamFoVHdJREFRQUJBb0lCQVFERGdaU3oyV2VDbk9DSApsUjlWV1V3MFY5UGVlbG9sVDBuZjA4dWUraExkWHFMc0labDNBYVJ6K1JaR1ZCeEo5L1FRdDF0eTd5M05NdldTCng5LzRMbVgrN1BoMWlTYTdpeWxBK3lMZ2E4VHBCSTB3enpOSmFmUlZsS2RONkJhVmxmWWdRMnV1RmsrUUJwWWYKTC80RlBtUk9KekxIcFJPaW9Tb2ZERis1amhpa0psWCtVanA1aVlOdlpoZ09XQXpRbUc5ZDNUOXc2Wm10djJTTQpPSGZJb2VjNys3MkxyNldnbWtHbkVNc1A1R3h1Umh5ODJCTmcrTGw4cklQai9lN2ppeFZwU3QvYVNoTzBpcVFPCjB5Z0dhUzZUcEhOazhiTjhxbm55MmNQdmZKZktPYUF2NU1jZ1ROd1FpdjYvYUNTL0hVZkphemQvNUtISlc0aVgKSEI4WXowYUpBb0dCQU82S3U3NUFnZE56ZWFYVUFwMUN3OEZ2YWpPRU1BbUZuQVpBNDNTdWN1NnErUVlIdDJrZwpERTBSYXJKR3pRV2FPdStOYUF4WnFBaHdpKzJJM2gyTFZlSHdPcHEvVWVjNHZXaTEzNWQ3ZGZUT1hHaFNqZWVjCmZOY3prUDR0NFdRVVlndHhnR3ZxYVIrbmNHdmxKcll3TlRSM2NZUGJZVk5lZDMvYjZMR1c0VEt6QW9HQkFPVGkKSGJBRE51Y2x1Q2MwZy9DZGtoWXhYbHZKaVRXa1p2a3g2Uk1Oc0JWa1UvaWVJT2V2ejluWFJnQU5jNDBzZ2RvSApVWCt4b3B6cFQ2ZDRNNlh5djNFMURGQm5XaFdWRzdwbjBBb1ErdUpVblNDYUdEMWN2QjJPTjVFN2NqdFpIMzl3Cm1PWnJPeWVGUUVSVm5sekNwZDA5TUdscktGSFEySndwcTZibmFIVDFBb0dBZU1MdlROK25XZjhKeExQU0p2OFgKenlPeVppWXprMzU2Z0lmMUhxcjZNRzJKNkUyYndyS2d4NXRib3FsSlBkN1ltMUhCTFE5dWkrYytUNkNNb2ZSYQpKQ25UNFdlZDlTcTZhUG82R1p3OUdSUW5vQUM3S2xnRXM0VzlqNUIybkkzZEhPSDNHNnJ1VVVJWkhlWkNkTlZ1CitnTEdDdlRURHJ1eVQ1NXE3UXp2TVJVQ2dZQk1WMHIxb1N6WHpoSHRLYXYwUG1veWNzYjVNSEJPYndaVmlac20KMnNMbmI2NCtWMmU4UHp6QmVQY0ZIM2R5RiswN3JvTTFaeWRJMU56WGk5VVdQYkF5N3pHclE3MmRRejJiWC9MWQoySzhGZkpsbi9WMm1ZZDd3c0xYQ0FDVHF2S0F2M250eEowVDB1cElqK0xhNFU4Z0UwZHJxM20zMVZBWmJsOTZECjdkMCtYUUtCZ0VrZ3ZRMHJidHc1QXcrVGFpSi9YaEZEQVNZT01FRUV1VjBrS3Qvc2ZsVUVtZ3luUmhTRzU0Y2cKR0o3eGN4UFFDak43NHBvZzY1QmE0MzJaeVVUdTB1cDhQVmJSTFhYRHRjdjM2YUl6ZGdSRk1PTG0zY3BySlpHMgpGdTZRU1JLWXUxangvT21XSytjRzdpYWplZlBwU25FVDNiTzYvY2xMdzFuMjlYM1M4UEFhCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg=="

  flux_registry_endpoint = "registry.dfds.cloud"
  flux_registry_username = "flux"
  flux_registry_password = "Flux12345"
  flux_registry_email    = "flux@dfds.com"

}

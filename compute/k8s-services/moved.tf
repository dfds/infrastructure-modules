# --------------------------------------------------
# Automatic migration of terraform state
# --------------------------------------------------

moved {
  from = module.traefik_alb_auth_appreg[0].azuread_application.app
  to   = module.traefik_alb_auth_appreg.azuread_application.app
}

moved {
  from = module.traefik_alb_auth_appreg[0].azuread_service_principal.sp
  to   = module.traefik_alb_auth_appreg.azuread_service_principal.sp
}

moved {
  from = module.traefik_alb_auth_appreg[0].azuread_service_principal_password.key
  to   = module.traefik_alb_auth_appreg.azuread_service_principal_password.key
}

moved {
  from = module.traefik_alb_auth_appreg[0].random_password.password
  to   = module.traefik_alb_auth_appreg.random_password.password
}

moved {
  from = module.monitoring_namespace[0].kubernetes_namespace.namespace
  to   = module.monitoring_namespace.kubernetes_namespace.namespace
}

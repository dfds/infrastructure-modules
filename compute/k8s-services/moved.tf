moved {
  from = module.monitoring_namespace[0].kubernetes_namespace.namespace
  to   = module.monitoring_namespace.kubernetes_namespace.namespace
}

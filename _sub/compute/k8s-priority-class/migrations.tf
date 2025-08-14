moved {
  from = kubernetes_priority_class.class[0]
  to   = kubernetes_priority_class.class["service-critical"]
}

moved {
  from = kubernetes_priority_class.class[1]
  to   = kubernetes_priority_class.class["cluster-monitoring"]
}

moved {
  from = kubernetes_priority_class.class[2]
  to   = kubernetes_priority_class.class["selfservice"]
}

moved {
  from = kubernetes_priority_class.class[3]
  to   = kubernetes_priority_class.class["high"]
}

moved {
  from = kubernetes_priority_class.class[4]
  to   = kubernetes_priority_class.class["low"]
}
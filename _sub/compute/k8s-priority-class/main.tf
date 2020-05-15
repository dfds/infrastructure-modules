resource "kubernetes_priority_class" "class" {
  count = length(var.priority_class)
  metadata {
    name = var.priority_class[count.index].name
  }

  description = var.priority_class[count.index].description
  value       = var.priority_class[count.index].priority
  global_default = try(var.priority_class[count.index].default, false) 
}

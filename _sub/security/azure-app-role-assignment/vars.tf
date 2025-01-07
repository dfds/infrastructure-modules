variable "role_assignments" {
  type = list(object({
    principal_id = string
    app_role_id  = string
    resource_id  = string
  }))
  description = <<DESCRIPTION
    A map of principal role assignments to create for applications.
    principal_id is the object ID of the user, group, or service principal to assign the app role to.
    app_role_id is the ID of the app role to assign.
    resource_id is the ID of the service principal representing the application to assign the app role to.
  DESCRIPTION
}
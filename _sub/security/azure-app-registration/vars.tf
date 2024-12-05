variable "name" {
  type        = string
  description = "The name of the app registration"
}

variable "homepage_url" {
  type        = string
  description = "The URL to the application's home page"
}

variable "identifier_uris" {
  type        = list(string)
  default     = []
  description = "A list of user-defined URI(s) that uniquely identify a Web application within it's Azure AD tenant, or within a verified custom domain if the application is multi-tenant"
}

variable "redirect_uris" {
  type        = list(string)
  default     = []
  description = "A list of URLs that user tokens are sent to for sign in, or the redirect URIs that OAuth 2.0 authorization codes and access tokens are sent to"
}

variable "assignment_is_required" {
  type        = bool
  default     = false
  description = <<EOF
  If this option is set to true, then users and other apps or services must first be assigned this application before being able to access it.
  If this option is set to false, then all users will be able to sign in, and other apps and services will be able to obtain an access token to this service.
  EOF
}

variable "app_roles" {
  type        = list(object({
    allowed_member_types = list(string)
    description          = string
    display_name         = string
    enabled              = bool
    id                   = string
    value                = string
  }))
  default     = []
  description = "A list of app roles to create for the application. Note: allowed_member_types must be a list containing only 'User' or 'Application'"
}

variable "api_permissions" {
  type = object({
    roles = optional(list(string), [])
    scopes = optional(list(string), [])
  })
  default = null
  description = <<EOF
  A map of API permissions (Microsoft Graph) to assign to the application.
  roles is a list of roles to assign to the application. Example: ["User.Read.All"]
  scopes is a list of scopes to assign to the application. Example: ["email"]
  Important note: If the permissions require admin consent, then you can use the azure-app-delegated-permissions-grant module to grant those permissions.
  EOF
}
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


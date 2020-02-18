variable "deploy" {
  type    = bool
  default = true
}

variable "name" {
  type        = string
  description = "The name of the app registration"
}

variable "homepage" {
  type        = string
  description = "The URL to the application's home page"
}

variable "identifier_uris" {
  type        = list(string)
  default     = []
  description = "A list of user-defined URI(s) that uniquely identify a Web application within it's Azure AD tenant, or within a verified custom domain if the application is multi-tenant"
}

variable "reply_urls" {
  type        = list(string)
  default     = []
  description = "A list of URLs that user tokens are sent to for sign in, or the redirect URIs that OAuth 2.0 authorization codes and access tokens are sent to"
}

variable "appreg_key_bucket" {
  description = "The name of the S3 bucket in which to store a copy of the key file"
}

variable "appreg_key_key" {
  description = "The path and file name of the key file in the S3 bucket"
}

variable "grant_aad_access" {
  default     = false
  description = "Should an permission and grant be setup against Azure AD"
}


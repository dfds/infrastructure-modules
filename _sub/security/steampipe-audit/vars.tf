variable "allowed_account_id" {
    type = string
    description = "The account id that is allowed to assume the steampipe-audit role"
}

variable "allowed_principal_role_name" {
    type = string
    description = "The name of the role that is allowed to assume the steampipe-audit role"
}
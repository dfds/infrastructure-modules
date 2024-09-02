resource "aws_account_alternate_contact" "contact" {
  alternate_contact_type = var.contact_type
  email_address          = var.email
  name                   = "${var.contact_type} email"
  phone_number           = var.phone_number
  title                  = var.contact_type
}

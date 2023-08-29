variable "aws_region" {
  type = string
}

variable "delegated_administrators" {
  type = list(object({
    account_id = string
    service_principal = string
  }))
  description = "List of delegated administrators to be configured. Each objects consists of the `account_id` which will be registered as a delegated administrator and a `service_principal` which will be the AWS service to make the member account an administrator of."
}

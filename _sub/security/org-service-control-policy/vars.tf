variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "policy" {
  type = string
  # The idea for this validation comes from: https://notes.hatedabamboo.me/checking-iam-policy-length-using-terraform/
  validation {
    condition = length(replace(replace(var.policy, " ", ""), "\n", "")) < 6144
    error_message = "Length of the policy is more than 6144 symbols, current length is: ${length(replace(replace(var.policy, " ", ""), "\n", ""))}"
  }
}

variable "attach_targets" {
  type = list(string)
}

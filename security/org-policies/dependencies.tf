locals {   
  bedrock_exempted_principal_arns = concat(
    [
      "arn:aws:iam::*:role/OrgRole",
      "arn:aws:iam::*:role/aws-config-recorder*"
    ],
    formatlist("arn:aws:iam::%s:role/*", var.bedrock_exempted_accounts)
  )
}

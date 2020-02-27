# data "aws_iam_account_alias" "current" {}

data "aws_subnet" "subnet_0" {
  id = element(var.subnet_ids, 0)
}

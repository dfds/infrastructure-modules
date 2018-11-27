data "aws_iam_role" "aws_org_role" {
  name = "${var.aws_org_rolename}"

  provider = "aws.workload"
}
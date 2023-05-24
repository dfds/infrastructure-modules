resource "aws_iam_user" "user" {
  name = var.user_name
}

resource "aws_iam_user_group_membership" "user" {
  user   = aws_iam_user.user.name
  groups = var.group_memberships
}

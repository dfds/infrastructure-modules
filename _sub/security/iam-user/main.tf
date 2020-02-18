resource "aws_iam_user" "user" {
  name = var.user_name
}

resource "aws_iam_user_policy" "policy" {
  name   = var.user_policy_name
  user   = aws_iam_user.user.id
  policy = var.user_policy_document
}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.user.name
}


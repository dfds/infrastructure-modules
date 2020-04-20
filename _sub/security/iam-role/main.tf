resource "aws_iam_role" "role" {
  name                 = var.role_name
  path                 = var.role_path
  description          = var.role_description
  assume_role_policy   = var.assume_role_policy
  max_session_duration = var.max_session_duration
}

resource "aws_iam_role_policy" "policy" {
  name   = var.role_policy_name
  role   = aws_iam_role.role.id
  policy = var.role_policy_document
}


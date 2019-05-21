resource "aws_iam_role" "role" {
  name               = "${var.role_name}"
  description        = "${var.role_description}"
  assume_role_policy = "${var.assume_role_policy}"
}

resource "aws_iam_role_policy" "policy" {
  name   = "${var.role_policy_name}"
  role   = "${aws_iam_role.role.id}"
  policy = "${var.role_policy_document}"
}
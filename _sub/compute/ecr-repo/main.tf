resource "aws_ecr_repository" "repo" {
  for_each = var.names
  name     = each.key

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_repository_policy" "policy" {
  for_each   = var.names
  repository = each.key

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "Allow pull from AWS IAM principals",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(var.pull_principals)}
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF

  depends_on = [aws_ecr_repository.repo]

}
